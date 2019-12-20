#!/bin/bash
#sudo git clone https://github.com/j13tw/School_Monitor_System.git /home/pi/
read -p "請輸入學校代碼：" sn;
sudo python3 /home/pi/Librenms_auto_build/Client/enviroment.py
sudo nohup python3 -u /home/pi/Librenms_auto_build/Client/selfCheck.py ${sn} > /home/pi/client.log 2>&1 &

