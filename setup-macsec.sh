#!/bin/bash
set -e

# Configuration
ETH_IFACE="eth0"
LOCAL_MAC="2c:cf:67:98:8e:92"
PEER_MAC="2c:cf:67:98:8e:52"
LOCAL_IP="192.168.10.1/24"
PEER_IP="192.168.10.2"

echo "Configuration loaded"

# Load MACsec key from file
KEY=$(cat keys/macseckey)

echo "Key loaded"

# Delete existing MACsec interface if present
ip link del macsec0 2>/dev/null || true

echo "Cleaned up any existing macsec0 interface"

# Create MACsec interface
ip link add link $ETH_IFACE macsec0 type macsec encrypt on

echo "MACsec interface created"

# Configure TX Secure Association (SA)
ip macsec add macsec0 tx sa 0 pn 1 on key 00 $KEY encrypt on

echo "TX SA configured"

# Configure RX Secure Channel and Secure Association (SA)
ip macsec add macsec0 rx address $PEER_MAC port 1
ip macsec add macsec0 rx address $PEER_MAC port 1 sa 0 pn 1 on key 00 $KEY encrypt on

echo "RX SA Channel configured"

# Bring up interface and assign IP address
ip link set macsec0 up
ip addr add $LOCAL_IP dev macsec0

echo "MACsec configured on $ETH_IFACE as macsec0"
