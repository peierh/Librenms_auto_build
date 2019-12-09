#!/bin/bash
read -p "輸入dbuser: " dbuser;
read -p "輸入LibrenmsUSER: " uiuser;
read -p "輸入DBname: " dbname;

sudo chmod 777 Librenms_auto_build/auto_build/config.json
sudo sed -i "3c \"name\":\"${dbuser}\"," Librenms_auto_build/auto_build/config.json
sudo sed -i "7c \"user\":\"${uiuser}\"," Librenms_auto_build/auto_build/config.json
sudo sed -i "9c \"database\":\"${dbname}\"," Librenms_auto_build/auto_build/config.json
