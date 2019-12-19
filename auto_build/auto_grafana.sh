#!/bin/bash
sudo git clone https://github.com/j13tw/School_Monitor_System.git /home/pi/
sudo python3 /home/pi/School_Monitor_System/Client/enviroment.py
sudo nohup python3 -u /home/pi/School_Monitor_System/Client/selfCheck.py 7777 > /home/pi/client.log 2>&1 &

