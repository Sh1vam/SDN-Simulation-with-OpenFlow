#!/usr/bin/env python3
"""
Network Statistics Generator for Mininet SDN Topologies
Displays comprehensive network statistics and traffic analysis

Usage: mininet> py exec(open('network_stats.py').read())
"""

import subprocess
import json
from collections import defaultdict

def run_cmd(cmd):
    """Execute a shell command and return output"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=5)
        return result.stdout
    except Exception as e:
        return f"Error: {e}"

def get_switch_flows(switch_name):
    """Get all flows for a switch"""
    cmd = f"sudo ovs-ofctl dump-flows {switch_name}"
    output = run_cmd(cmd)
    lines = output.strip().split('\n')[1:]  # Skip header
    return len([l for l in lines if l.strip() and not l.startswith('OFPST')])

def get_switch_ports(switch_name):
    """Get port statistics for a switch"""
    cmd = f"sudo ovs-ofctl dump-ports {switch_name}"
    output = run_cmd(cmd)
    
    stats = {
        'total_ports': 0,
        'total_rx_packets': 0,
        'total_tx_packets': 0,
        'total_rx_bytes': 0,
        'total_tx_bytes': 0,
        'total_errors': 0
    }
    
    for line in output.split('\n'):
        if 'rx pkts=' in line:
            # Parse port statistics
            parts = line.split()
            for part in parts:
                if part.startswith('rx'):
                    try:
                        metric, value = part.split('=')
                        value = int(value.rstrip(','))
                        if metric == 'rx':
                            stats['total_rx_packets'] += value
                        elif metric == 'tx':
                            stats['total_tx_packets'] += value
                    except:
                        pass
                elif part.startswith('bytes='):
                    try:
                        value = int(part.split('=')[1].rstrip(','))
                        stats['total_rx_bytes'] += value
                    except:
                        pass
            stats['total_ports'] += 1
    
    return stats

def get_all_switch_stats():
    """Collect statistics from all switches"""
    cmd = "sudo ovs-vsctl list-br"
    output = run_cmd(cmd)
    switches = output.strip().split('\n')
    
    switch_stats = {}
    for switch in switches:
        if switch.strip():
            stats = get_switch_ports(switch)
            flows = get_switch_flows(switch)
            switch_stats[switch] = {
                'flows': flows,
                'ports': stats['total_ports'],
                'rx_packets': stats['total_rx_packets'],
                'tx_packets': stats['total_tx_packets'],
                'rx_bytes': stats['total_rx_bytes'],
                'tx_bytes': stats['total_tx_bytes']
            }
    
    return switch_stats

def display_network_stats():
    """Display comprehensive network statistics"""
    
    print("\n" + "="*80)
    print("🌐 NETWORK STATISTICS REPORT")
    print("="*80)
    
    # Get switch stats
    switch_stats = get_all_switch_stats()
    
    print("\n📊 SWITCH OVERVIEW:")
    print("-"*80)
    print(f"{'Switch':<10} {'Flows':<8} {'Ports':<8} {'RX Pkts':<12} {'TX Pkts':<12} {'RX Bytes':<12}")
    print("-"*80)
    
    total_flows = 0
    total_ports = 0
    total_rx_pkts = 0
    total_tx_pkts = 0
    
    for switch_name in sorted(switch_stats.keys()):
        stats = switch_stats[switch_name]
        total_flows += stats['flows']
        total_ports += stats['ports']
        total_rx_pkts += stats['rx_packets']
        total_tx_pkts += stats['tx_packets']
        
        print(f"{switch_name:<10} {stats['flows']:<8} {stats['ports']:<8} "
              f"{stats['rx_packets']:<12} {stats['tx_packets']:<12} {stats['rx_bytes']:<12}")
    
    print("-"*80)
    print(f"{'TOTAL':<10} {total_flows:<8} {total_ports:<8} "
          f"{total_rx_pkts:<12} {total_tx_pkts:<12}")
    
    # Get network topology info
    print("\n🏗️  NETWORK TOPOLOGY:")
    print("-"*80)
    
    # Count hosts vs switches
    hosts_output = run_cmd("sudo ip netns list 2>/dev/null | wc -l")
    try:
        num_hosts = int(hosts_output.strip())
    except:
        num_hosts = 0
    
    num_switches = len(switch_stats)
    
    print(f"Switches: {num_switches}")
    print(f"Hosts: {num_hosts}")
    print(f"Total Ports: {total_ports}")
    
    # Flow distribution
    if num_switches > 0:
        avg_flows = total_flows / num_switches
        print(f"\nAverage Flows per Switch: {avg_flows:.1f}")
        
        max_flows = max(s['flows'] for s in switch_stats.values())
        min_flows = min(s['flows'] for s in switch_stats.values())
        print(f"Max Flows on Switch: {max_flows}")
        print(f"Min Flows on Switch: {min_flows}")
    
    # Traffic analysis
    print("\n📈 TRAFFIC ANALYSIS:")
    print("-"*80)
    
    total_packets = total_rx_pkts + total_tx_pkts
    total_bytes_transferred = total_rx_pkts + total_tx_pkts  # Simplified
    
    print(f"Total Packets Seen: {total_packets:,}")
    print(f"Total RX Packets: {total_rx_pkts:,}")
    print(f"Total TX Packets: {total_tx_pkts:,}")
    
    if total_packets > 0:
        print(f"\nTraffic Balance:")
        print(f"  RX Ratio: {(total_rx_pkts/total_packets)*100:.1f}%")
        print(f"  TX Ratio: {(total_tx_pkts/total_packets)*100:.1f}%")
    
    # Switch classification
    print("\n🔀 SWITCH CLASSIFICATION:")
    print("-"*80)
    
    edge_switches = []
    core_switches = []
    
    for switch_name in sorted(switch_stats.keys()):
        if switch_name.startswith('s') and int(switch_name[1:]) <= 6:
            edge_switches.append(switch_name)
        else:
            core_switches.append(switch_name)
    
    if edge_switches:
        print(f"Edge Switches: {', '.join(edge_switches)}")
        avg_edge_flows = sum(switch_stats[s]['flows'] for s in edge_switches) / len(edge_switches)
        print(f"  Average Flows: {avg_edge_flows:.1f}")
    
    if core_switches:
        print(f"Core Switches: {', '.join(core_switches)}")
        avg_core_flows = sum(switch_stats[s]['flows'] for s in core_switches) / len(core_switches)
        print(f"  Average Flows: {avg_core_flows:.1f}")
    
    # Detailed flow analysis
    print("\n🔍 DETAILED FLOW ANALYSIS:")
    print("-"*80)
    
    for switch_name in sorted(switch_stats.keys()):
        stats = switch_stats[switch_name]
        if stats['flows'] > 0:
            print(f"\n{switch_name} ({stats['flows']} flows):")
            
            # Get flow details
            cmd = f"sudo ovs-ofctl dump-flows {switch_name} 2>/dev/null | grep -v OFPST"
            flows_output = run_cmd(cmd)
            
            # Count flow types
            flow_count = 0
            for line in flows_output.split('\n'):
                if line.strip() and 'table=' in line:
                    flow_count += 1
                    if flow_count <= 3:  # Show first 3 flows as example
                        # Extract key parts
                        if 'actions=' in line:
                            action = line.split('actions=')[1].split()[0] if 'actions=' in line else 'N/A'
                            print(f"  Flow {flow_count}: actions={action}")
            
            if stats['flows'] > 3:
                print(f"  ... and {stats['flows']-3} more flows")
    
    # Health status
    print("\n✅ NETWORK HEALTH:")
    print("-"*80)
    
    if total_flows > 0:
        print("✓ OpenFlow flows installed and active")
    else:
        print("⚠ No OpenFlow flows detected")
    
    if total_rx_pkts > 0 or total_tx_pkts > 0:
        print("✓ Traffic flowing through network")
    else:
        print("⚠ No traffic observed (may need to generate traffic)")
    
    if num_hosts > 0:
        print(f"✓ Network has {num_hosts} active hosts")
    
    print("\n" + "="*80)
    print("Report generated at", run_cmd("date").strip())
    print("="*80 + "\n")

# Run the statistics
try:
    display_network_stats()
except Exception as e:
    print(f"\n❌ Error generating statistics: {e}")
    print("Make sure you have sudo privileges and are running in a terminal with network access")
