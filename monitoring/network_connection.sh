#/bin/usr/env bash
while true 
do
echo "TCP metrics"
echo "$HOSTNAME.veal.total_network_connection.tcp $(conntrack -L 2>/dev/null | grep tcp | wc -l ) $(date +%s)"| nc -C graphite.aunalytics.com 2003
echo "UDP metrics"
echo "$HOSTNAME.veal.total_network_connection.udp $(conntrack -L 2>/dev/null | grep udp | wc -l ) $(date +%s)"| nc -C graphite.aunalytics.com 2003
sleep 10    
done

