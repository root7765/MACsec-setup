#!/bin/bash
set -e

#Einstellungen
ETH_IFACE="eth0"
LOCAL_MAC="aa:bb:cc:dd:ee:01"
PEER_MAC="aa:bb:cc:dd:ee:02"
LOCAL_IP="192.168.10.1/24"
PEER_IP="192.168.10.2"

#Schlüssel einlesen
KEY=$(cat keys/macsec.key)

#Vorherige MACsec-Verbindung löschen, falls vorhanden
ip link del macsec0 2>/dev/null || true

#macsec0 erstellen
ip link add link $ETH_IFACE macsec0 type macsec

#TX SA einrichten
ip macsec add macsec0 tx sa 0 pn 1 on key 00 $KEY

#RX SA einrichten
ip macsec add macsec0 rx address $PEER_MAC port 1
ip macsec add macsec0 rx address $PEER_MAC port 1 sa 0 pn 1 on key 00 $KEY

#Interface aktivieren & IP setzen
ip link set macsec0 up
ip addr add $LOCAL_IP dev macsec0

echo "MACsec eingerichtet auf $ETH_IFACE als macsec0"
