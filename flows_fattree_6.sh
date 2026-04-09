#!/bin/bash

# OpenFlow Flows for Fat-Tree 6 Topology
# This script installs flows to enable all-to-all communication in the Fat-Tree network

echo "Installing OpenFlow flows for Fat-Tree 6 topology..."
echo "=================================================="

# Edge switches (s1-s6): Connect hosts to core via equal-cost multi-path (ECMP)
# Each edge switch has 3 connections to core switches (s7, s8, s9)

# S1 flows (connects h1, h2, h3 to s7, s8, s9)
echo "Adding flows to s1..."
sudo ovs-ofctl add-flow s1 "table=0,priority=1000,in_port=1,actions=output:4,5,6"  # h1 -> core
sudo ovs-ofctl add-flow s1 "table=0,priority=1000,in_port=2,actions=output:4,5,6"  # h2 -> core
sudo ovs-ofctl add-flow s1 "table=0,priority=1000,in_port=3,actions=output:4,5,6"  # h3 -> core
sudo ovs-ofctl add-flow s1 "table=0,priority=100,in_port=4,actions=output:1,2,3"   # core -> hosts
sudo ovs-ofctl add-flow s1 "table=0,priority=100,in_port=5,actions=output:1,2,3"   # core -> hosts
sudo ovs-ofctl add-flow s1 "table=0,priority=100,in_port=6,actions=output:1,2,3"   # core -> hosts

# S2 flows (connects h4, h5, h6 to s7, s8, s9)
echo "Adding flows to s2..."
sudo ovs-ofctl add-flow s2 "table=0,priority=1000,in_port=1,actions=output:4,5,6"
sudo ovs-ofctl add-flow s2 "table=0,priority=1000,in_port=2,actions=output:4,5,6"
sudo ovs-ofctl add-flow s2 "table=0,priority=1000,in_port=3,actions=output:4,5,6"
sudo ovs-ofctl add-flow s2 "table=0,priority=100,in_port=4,actions=output:1,2,3"
sudo ovs-ofctl add-flow s2 "table=0,priority=100,in_port=5,actions=output:1,2,3"
sudo ovs-ofctl add-flow s2 "table=0,priority=100,in_port=6,actions=output:1,2,3"

# S3 flows (connects h7, h8, h9 to s7, s8, s9)
echo "Adding flows to s3..."
sudo ovs-ofctl add-flow s3 "table=0,priority=1000,in_port=1,actions=output:4,5,6"
sudo ovs-ofctl add-flow s3 "table=0,priority=1000,in_port=2,actions=output:4,5,6"
sudo ovs-ofctl add-flow s3 "table=0,priority=1000,in_port=3,actions=output:4,5,6"
sudo ovs-ofctl add-flow s3 "table=0,priority=100,in_port=4,actions=output:1,2,3"
sudo ovs-ofctl add-flow s3 "table=0,priority=100,in_port=5,actions=output:1,2,3"
sudo ovs-ofctl add-flow s3 "table=0,priority=100,in_port=6,actions=output:1,2,3"

# S4 flows (connects h10, h11, h12 to s7, s8, s9)
echo "Adding flows to s4..."
sudo ovs-ofctl add-flow s4 "table=0,priority=1000,in_port=1,actions=output:4,5,6"
sudo ovs-ofctl add-flow s4 "table=0,priority=1000,in_port=2,actions=output:4,5,6"
sudo ovs-ofctl add-flow s4 "table=0,priority=1000,in_port=3,actions=output:4,5,6"
sudo ovs-ofctl add-flow s4 "table=0,priority=100,in_port=4,actions=output:1,2,3"
sudo ovs-ofctl add-flow s4 "table=0,priority=100,in_port=5,actions=output:1,2,3"
sudo ovs-ofctl add-flow s4 "table=0,priority=100,in_port=6,actions=output:1,2,3"

# S5 flows (connects h13, h14, h15 to s7, s8, s9)
echo "Adding flows to s5..."
sudo ovs-ofctl add-flow s5 "table=0,priority=1000,in_port=1,actions=output:4,5,6"
sudo ovs-ofctl add-flow s5 "table=0,priority=1000,in_port=2,actions=output:4,5,6"
sudo ovs-ofctl add-flow s5 "table=0,priority=1000,in_port=3,actions=output:4,5,6"
sudo ovs-ofctl add-flow s5 "table=0,priority=100,in_port=4,actions=output:1,2,3"
sudo ovs-ofctl add-flow s5 "table=0,priority=100,in_port=5,actions=output:1,2,3"
sudo ovs-ofctl add-flow s5 "table=0,priority=100,in_port=6,actions=output:1,2,3"

# S6 flows (connects h16, h17, h18 to s7, s8, s9)
echo "Adding flows to s6..."
sudo ovs-ofctl add-flow s6 "table=0,priority=1000,in_port=1,actions=output:4,5,6"
sudo ovs-ofctl add-flow s6 "table=0,priority=1000,in_port=2,actions=output:4,5,6"
sudo ovs-ofctl add-flow s6 "table=0,priority=1000,in_port=3,actions=output:4,5,6"
sudo ovs-ofctl add-flow s6 "table=0,priority=100,in_port=4,actions=output:1,2,3"
sudo ovs-ofctl add-flow s6 "table=0,priority=100,in_port=5,actions=output:1,2,3"
sudo ovs-ofctl add-flow s6 "table=0,priority=100,in_port=6,actions=output:1,2,3"

# Core switches (s7, s8, s9): Forward between all edge switches using ECMP
# S7 core switch - connected to s1(1), s2(2), s3(3), s4(4), s5(5), s6(6)
echo "Adding flows to s7 (core)..."
sudo ovs-ofctl add-flow s7 "table=0,priority=1000,in_port=1,actions=output:2,3,4,5,6"  # From s1 -> distribute
sudo ovs-ofctl add-flow s7 "table=0,priority=1000,in_port=2,actions=output:1,3,4,5,6"  # From s2 -> distribute
sudo ovs-ofctl add-flow s7 "table=0,priority=1000,in_port=3,actions=output:1,2,4,5,6"  # From s3 -> distribute
sudo ovs-ofctl add-flow s7 "table=0,priority=1000,in_port=4,actions=output:1,2,3,5,6"  # From s4 -> distribute
sudo ovs-ofctl add-flow s7 "table=0,priority=1000,in_port=5,actions=output:1,2,3,4,6"  # From s5 -> distribute
sudo ovs-ofctl add-flow s7 "table=0,priority=1000,in_port=6,actions=output:1,2,3,4,5"  # From s6 -> distribute

# S8 core switch - connected to s1(1), s2(2), s3(3), s4(4), s5(5), s6(6)
echo "Adding flows to s8 (core)..."
sudo ovs-ofctl add-flow s8 "table=0,priority=1000,in_port=1,actions=output:2,3,4,5,6"
sudo ovs-ofctl add-flow s8 "table=0,priority=1000,in_port=2,actions=output:1,3,4,5,6"
sudo ovs-ofctl add-flow s8 "table=0,priority=1000,in_port=3,actions=output:1,2,4,5,6"
sudo ovs-ofctl add-flow s8 "table=0,priority=1000,in_port=4,actions=output:1,2,3,5,6"
sudo ovs-ofctl add-flow s8 "table=0,priority=1000,in_port=5,actions=output:1,2,3,4,6"
sudo ovs-ofctl add-flow s8 "table=0,priority=1000,in_port=6,actions=output:1,2,3,4,5"

# S9 core switch - connected to s1(1), s2(2), s3(3), s4(4), s5(5), s6(6)
echo "Adding flows to s9 (core)..."
sudo ovs-ofctl add-flow s9 "table=0,priority=1000,in_port=1,actions=output:2,3,4,5,6"
sudo ovs-ofctl add-flow s9 "table=0,priority=1000,in_port=2,actions=output:1,3,4,5,6"
sudo ovs-ofctl add-flow s9 "table=0,priority=1000,in_port=3,actions=output:1,2,4,5,6"
sudo ovs-ofctl add-flow s9 "table=0,priority=1000,in_port=4,actions=output:1,2,3,5,6"
sudo ovs-ofctl add-flow s9 "table=0,priority=1000,in_port=5,actions=output:1,2,3,4,6"
sudo ovs-ofctl add-flow s9 "table=0,priority=1000,in_port=6,actions=output:1,2,3,4,5"

echo "=================================================="
echo "✅ All flows installed successfully!"
echo ""
echo "Flow Summary:"
echo "- Edge switches (s1-s6): Forward host traffic to core with ECMP (multi-path)"
echo "- Core switches (s7-s9): Distribute traffic across all edge switches"
echo ""
echo "Verify flows with: sudo ovs-ofctl dump-flows s1"
