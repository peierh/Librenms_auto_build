#!/bin/bash
ip=$(hostname -I)
lenth=${#ip}
ipnew=${ip:0:lenth-1}

echo $ip

#sudo sed -i "33c \$config['snmp']['community'][] = \"a123456\";" /opt/librenms/config.php
#sudo sed -i "34c \$config['nets'][] = \"$ipnew/32\"; " /opt/librenms/config.php
#sudo sed -i "35c \$config['autodiscovery']['nets-exclude'][] = '$ipnew/32';" /opt/librenms/config.php
#sudo sed -i "36c \$config['allow_duplicate_sysName'] = true; " /opt/librenms/config.php
#sudo sed -i "37c \$config['discovery_by_ip'] = true; " /opt/librenms/config.php
#sudo sed -i "38c \$config['discovery_modules']['discover-arp'] = true; " /opt/librenms/config.php
#/opt/librenms/snmp-scan.py
