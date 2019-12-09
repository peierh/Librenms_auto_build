#!/bin/bash
ip=$(hostname -I)
echo $ip

#sudo sed -i "34c \$config['nets'][] = \"$ip/32\"; " /opt/librenms/config.php
/opt/librenms/snmp-scan.py
