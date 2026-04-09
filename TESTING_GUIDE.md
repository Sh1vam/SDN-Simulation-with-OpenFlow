# SDN Simulation Testing Guide

## Overview

This guide explains how to use the new testing and analysis tools for your SDN simulation project.

---

## 🚀 Quick Start: Complete Workflow

### Option 1: Fat-Tree 6 Topology with Flows

**Terminal 1 - Start Topology:**
```bash
cd /workspaces/SDN-Simulation-with-OpenFlow
sudo mn --custom FatTree_6.py --topo=mytopo --switch ovs --controller=none
```

Wait for `mininet>` prompt to appear.

**Terminal 2 - Install Flows (while Mininet is running):**
```bash
cd /workspaces/SDN-Simulation-with-OpenFlow
sudo bash flows_fattree_6.sh
```

**Terminal 1 - Verify Installation:**
```
mininet> sh sudo ovs-ofctl dump-flows s1
```

---

## 📊 Testing Tools

### 1. **Network Connectivity Test** (`test_connectivity.py`)

**Purpose:** Verify all hosts can reach each other through the network layer

**Usage (inside Mininet CLI):**
```bash
mininet> py exec(open('test_connectivity.py').read())
```

**What it does:**
- Tests Layer 2-3 connectivity between all host pairs
- Generates a connectivity matrix
- Shows IP addresses and MAC addresses
- Lists all active switches and their ports
- Provides a summary report

**Expected Output:**
```
======================================================================
MININET NETWORK CONNECTIVITY TEST
======================================================================

Testing 18 hosts: ['h1', 'h2', 'h3', ..., 'h18']

Testing Layer 3 Connectivity (routing):
----------------------------------------------------------------------
h1 (10.0.0.1  ) <-> h2 (10.0.0.2  ) | ✓ PASS
h1 (10.0.0.1  ) <-> h3 (10.0.0.3  ) | ✓ PASS
...
```

---

### 2. **Network Statistics** (`network_stats.py`)

**Purpose:** Generate comprehensive statistics about the running network

**Usage (from terminal, outside Mininet):**
```bash
cd /workspaces/SDN-Simulation-with-OpenFlow
python3 network_stats.py
```

Or **from within Mininet:**
```bash
mininet> sh cd /workspaces/SDN-Simulation-with-OpenFlow && python3 network_stats.py
```

**What it shows:**
- Switch overview (flows, ports, packet counts)
- Network topology (hosts, switches, ports)
- Traffic analysis (RX/TX packets, bytes)
- Switch classification (edge vs core)
- Flow distribution
- Network health status

**Example Output:**
```
================================================================================
🌐 NETWORK STATISTICS REPORT
================================================================================

📊 SWITCH OVERVIEW:
Switch     Flows    Ports    RX Pkts    TX Pkts    RX Bytes    
s1         6        6        54         66         4224        
s2         6        6        54         66         4224        
...

🏗️  NETWORK TOPOLOGY:
Switches: 9
Hosts: 18
Total Ports: 54

🔀 SWITCH CLASSIFICATION:
Edge Switches: s1, s2, s3, s4, s5, s6
  Average Flows: 6.0
Core Switches: s7, s8, s9
  Average Flows: 18.0
```

---

### 3. **Fat-Tree 6 Flows** (`flows_fattree_6.sh`)

**Purpose:** Install OpenFlow rules to enable multi-path routing in Fat-Tree topology

**Flow Strategy:**
- **Edge Switches (s1-s6):** Forward host traffic to all 3 core switches (ECMP - Equal-Cost Multi-Path)
- **Core Switches (s7-s9):** Distribute traffic across all edge switches

**Installation:**
```bash
# While Mininet topology is running
sudo bash flows_fattree_6.sh
```

**Verify Flows:**
```bash
# Check flows on each switch
sudo ovs-ofctl dump-flows s1
sudo ovs-ofctl dump-flows s7
```

---

## 🔧 Complete Test Scenarios

### Scenario 1: Test Simple Topology with Flows

```bash
# Terminal 1: Start simple topology
cd /workspaces/SDN-Simulation-with-OpenFlow
sudo mn --custom topology.py --topo=mytopo --switch ovs --controller=none

# Terminal 2: Install flows (after mininet> prompt appears)
cd /workspaces/SDN-Simulation-with-OpenFlow
sudo bash flows.sh

# Terminal 1: Check network stats
mininet> sh python3 network_stats.py

# Terminal 1: View flows
mininet> sh sudo ovs-ofctl dump-flows s1
```

### Scenario 2: Test Fat-Tree 6 Topology with Analysis

```bash
# Terminal 1: Start Fat-Tree 6 topology
cd /workspaces/SDN-Simulation-with-OpenFlow
sudo mn --custom FatTree_6.py --topo=mytopo --switch ovs --controller=none

# Terminal 2: Install flows
cd /workspaces/SDN-Simulation-with-OpenFlow
sudo bash flows_fattree_6.sh

# Terminal 1: Run connectivity test
mininet> py exec(open('test_connectivity.py').read())

# Terminal 1: Check detailed switch statistics
mininet> sh sudo ovs-ofctl dump-ports s1
mininet> sh sudo ovs-ofctl dump-ports s7

# Terminal 2: Generate comprehensive report
python3 network_stats.py
```

### Scenario 3: Monitor Real-Time Traffic

```bash
# Terminal 1: Start topology and flows
# (as in Scenario 2)

# Terminal 2: Watch switch port statistics in real-time
watch -n 1 'sudo ovs-ofctl dump-ports s1'

# Terminal 3: Continuous statistics generation
watch -n 5 'python3 network_stats.py'

# Terminal 1: In Mininet CLI, generate traffic
mininet> h1 python3 -c "import os; [os.system('echo test | dd of=/dev/null') for _ in range(1000)]"
```

---

## 📋 Commands Reference

### OVS Management
```bash
# See all bridges (switches)
sudo ovs-vsctl list-br

# List all ports on a switch
sudo ovs-ofctl show s1

# Dump all flows on a switch
sudo ovs-ofctl dump-flows s1

# Dump port statistics
sudo ovs-ofctl dump-ports s1

# View switch info
sudo ovs-vsctl get-config br-s1

# Enable more verbose logging
sudo ovs-vsctl set Log module:vconn facility:file level:dbg
```

### Mininet CLI Commands
```bash
mininet> nodes              # List all nodes
mininet> net                # Show network topology
mininet> dump               # Show detailed node info
mininet> links              # Show all links
mininet> sh <command>       # Run shell command
mininet> py <python code>   # Run Python code
mininet> exit               # Exit Mininet
```

### Network Diagnostics
```bash
# Check host network config
mininet> h1 ip addr show
mininet> h1 ip route
mininet> h1 ip neigh

# Get ARP info
mininet> h1 arp -a
```

---

## 🐛 Troubleshooting

### Issue: "No route to host" or connectivity failures

**Solution:**
1. Check if flows are installed:
   ```bash
   sudo ovs-ofctl dump-flows s1
   ```

2. Verify switch connectivity:
   ```bash
   sudo ovs-ofctl get-config br-s1
   ```

3. Check for errors:
   ```bash
   sudo ovs-vsctl get-fail-mode br-s1
   ```

### Issue: Mininet hangs or crashes

**Solution:**
1. Clean up residual processes:
   ```bash
   sudo mn -c
   ```

2. Restart OVSwitch:
   ```bash
   sudo service openvswitch-switch restart
   ```

3. Verify OVS is running:
   ```bash
   sudo ovs-vsctl show
   ```

### Issue: Permission denied errors

**Solution:**
All Mininet commands must run with `sudo`

---

## 📈 Performance Optimization Tips

1. **Use ECMP (Equal-Cost Multi-Path)** for balancing
2. **Set appropriate flow priorities** (higher number = higher priority)
3. **Batch flow installation** with scripts rather than one-at-a-time
4. **Monitor switch statistics** to identify bottlenecks
5. **Use wildcards** in OVS rules to reduce flow count

---

## 📚 Further Reading

- [OpenVSwitch Documentation](http://openvswitch.org/)
- [OpenFlow Specification](https://opennetworking.org/software-defined-standards/specifications/)
- [Mininet Documentation](http://mininet.org/)
- [Fat-Tree Network Architecture](https://www.usenix.org/conference/nsdi10/fattree-scalable-data-center-network-using-commodity-switches)

---

## ✅ Verification Checklist

- [ ] OVSwitch services running (`sudo service openvswitch-switch status`)
- [ ] Mininet installed (`which mn`)
- [ ] Topology creates successfully
- [ ] All switches and hosts present
- [ ] Flows installed without errors
- [ ] Network statistics show traffic
- [ ] Connectivity test passes
- [ ] Performance meets requirements

---

**Last Updated:** April 9, 2026
