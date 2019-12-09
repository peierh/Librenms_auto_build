#!/bin/bash
ip=$(hostname -I)
lenth=${#ip}
ipnew=${ip:0:lenth-1}

sudo sed -i "34c \$config['nets'][] = \"$ipnew/32\"; " /opt/librenms/config.php
/opt/librenms/snmp-scan.py
