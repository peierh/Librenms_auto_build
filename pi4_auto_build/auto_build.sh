#!/bin/bash

echo ==================== Start Install ====================

# change timezon
sudo cp /usr/share/zoneinfo/Asia/Taipei /etc/localtime
while true;
do
	read -p "請輸入學校代碼: " sn;
#	echo "您的學校代碼是 $sn 嗎？"
	read -p "您輸入的學校代碼是 $sn 嗎? (是y/否n) " a1;
	if [ $a1 == "y" ]; then
		echo "已確認您的學校代碼是 $sn"
		break
	else
		echo "請重新輸入學校代碼"
	fi
done
read -p "輸入電子郵件: " uiemail;
#!/bin/bash  
# blog: http://lizhenliang.blog.51cto.com  
function check_ip() {      
local IP=$1      
VALID_CHECK=$(echo $cs|awk -F. '$1<=255&&$2<=255&&$3<=255&&$4<=255{print "yes"}')      
if echo $IP|grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" >/dev/null; then
	if [ $VALID_CHECK == "yes" ]; then
     		#echo "IP $IP  available!"
		#echo "請問您輸入的是 $IP 嗎？"
		read -p "請問您的IP是 $IP 嗎？ y(是)/n(否): " ans
		if [ $ans == "y" ];then
			echo "已確認您的 Core Switch IP 是: $IP"
			return 0
		else
			echo "請重新輸入 Core Switch IP"
			return 1 
		fi          
	else              
		#echo "IP $IP not available!"
		echo "Core Switch IP 格式錯誤，請重新輸入。"
  		return 1          
	fi      
else          
	echo "IP format error!"
	return 1
fi   }   
while true;
do      
	read -p "請輸入 Core Switch IP: " cs      
	check_ip $cs      [ $? -eq 0 ] && break  
done
while true;
do
	read -p"請輸入雲端 Server 資訊: " sip
	read -p"請問確認您輸入的雲端資訊 $sip 是否正確? (是y/否n) " a2
	if [ $a2 == "y" ]; then
		echo "已確認您輸入的雲端資訊是 $sip"
		break
       	else
		echo "請重新輸入雲端 Server 資訊"
 	fi		
done
#database data
dbuser=lib${sn}user
#read -p "輸入新資料庫使用者名稱: (學校代碼)" dbuser;
dbpass=lib${sn}pass
#read -p "輸入新資料庫密碼: " dbpass;
dbname=lib${sn}name
#read -p "輸入新資料庫: " dbname;

#SNMP community
comm=${sn}
#read -p "input snmp community: " comm;

#UI data
uiuser=${sn}user
#read -p "輸入LibreNMS使用者帳戶: " uiuser;
uipwd=${sn}pass
#read -p "輸入LibreNMS使用者密碼: " uipwd;

sudo chmod 777 Librenms_auto_build/auto_build/config.json
sudo sed -i "3c \"name\":\"${dbuser}\"," Librenms_auto_build/auto_build/config.json
sudo sed -i "7c \"user\":\"${uiuser}\"," Librenms_auto_build/auto_build/config.json
sudo sed -i "9c \"database\":\"${dbname}\"," Librenms_auto_build/auto_build/config.json

#change time
#while true;
#do
#	read -p "輸入現在日期、時間(example: 2019-10-10 10:10:10)" time;
#
#	if [ ! -n "$time" ]; then
#		echo "輸入現在日期、時間"
#		echo "example: 2019-10-10 10:10:10"
#	else
#		echo $time
#		break
#	fi
#done

#date -s "$time"
sudo apt update
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8" 
#start ssh
/etc/init.d/ssh start

# install packages
echo
echo ==================== Step1: Download and Install Packages ===================
sudo apt install software-properties-common -y
sudo apt-get install apt-transport-https lsb-release ca-certificates -y
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
sudo apt-get update
sudo apt-get install php7.2-cli -y
sudo apt update
sudo apt install vim curl -y
sudo apt install influxdb influxdb-client -y
sudo apt install apache2 composer fping git graphviz imagemagick libapache2-mod-php7.2 mariadb-client mariadb-server mtr-tiny nmap php7.2-cli php7.2-curl php7.2-gd php7.2-json php7.2-mbstring php7.2-mysql php7.2-snmp php7.2-xml php7.2-zip python-memcache python-mysqldb rrdtool snmp snmpd whois -y
sudo apt install python3 python3-pip python3-dev -y
# add librenms user
sudo useradd librenms -d /opt/librenms -M -r
sudo usermod -a -G librenms www-data

# download librenms
sudo chmod 777 /opt
cd /opt
sudo git clone https://github.com/librenms/librenms.git

# set permissions
sudo apt install acl -y
sudo chown -R librenms:librenms /opt/librenms
sudo chmod 777 /opt/librenms
sudo setfacl -d -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/
sudo setfacl -R -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/

#create influxdb user database
sudo service influxdb restart
sleep 5
sudo curl -i -G "http://localhost:8086/query" --data-urlencode "q=CREATE database ${dbname}"
sudo curl -i -G "http://localhost:8086/query" --data-urlencode "q=CREATE user ${dbuser} with password '${dbpass}'"
sudo curl -i -G "http://localhost:8086/query" --data-urlencode "q=grant all PRIVILEGES TO ${dbuser}"
sudo curl -i -G "http://localhost:8086/query" --data-urlencode "q=GRANT ALL ON ${dbname} TO ${dbuser}"

# install librenms
echo
echo ==================== Step2: Install LibreNMS  ====================
cd /opt/librenms
sudo ./scripts/composer_wrapper.php install --no-dev

# configure mysql
echo
echo ==================== Step3: Set Database Config  ====================
sudo systemctl restart mysql

sudo mysql --user="$root" --password=" "  --execute="CREATE DATABASE ${dbname} CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
sudo mysql --user="$root" --password=" "  --execute="CREATE USER '${dbuser}'@'%' IDENTIFIED BY '${dbpass}';"
sudo mysql --user="$root" --password=" "  --execute="GRANT ALL PRIVILEGES ON ${dbname}.* TO '${dbuser}'@'%';"
sudo mysql --user="$root" --password=" "  --execute="FLUSH PRIVILEGES;"

sudo sed -i "13c innodb_file_per_table=1" /etc/mysql/mariadb.conf.d/50-server.cnf
sudo sed -i "13a lower_case_table_names=0" /etc/mysql/mariadb.conf.d/50-server.cnf
sudo sed -i "31c #bind-address       = 127.0.0.1" /etc/mysql/mariadb.conf.d/50-server.cnf

sudo systemctl restart mysql

# configure php
sudo sed -i "941c date.timezone = "Asia/Taipei"" /etc/php/7.2/apache2/php.ini
sudo sed -i "941c date.timezone = "Asia/Taipei"" /etc/php/7.2/cli/php.ini

sudo a2enmod php7.2
sudo a2dismod mpm_event
sudo a2enmod mpm_prefork

sudo cat > /etc/apache2/sites-available/librenms.conf <<EOF
<VirtualHost *:80>
  DocumentRoot /opt/librenms/html/
  ServerName  $HOSTNAME.local
  
  AllowEncodedSlashes NoDecode
  <Directory "/opt/librenms/html/">
    Require all granted
	AllowOverride All
	Options FollowSymLinks MultiViews
  </Directory>
</VirtualHost>
EOF

sudo a2dissite 000-default
sudo a2ensite librenms.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

# configure snmp
sudo cp /opt/librenms/snmpd.conf.example /etc/snmp/snmpd.conf

sudo sed -i "2c com2sec readonly  default        ${comm} # RANDOMSTRINGGOESHERE" /etc/snmp/snmpd.conf

sudo curl -o /usr/bin/distro https://raw.githubusercontent.com/librenms/librenms-agent/master/snmp/distro
sudo chmod +x /usr/bin/distro
sudo systemctl restart snmpd

# cron job
sudo cp /opt/librenms/librenms.nonroot.cron /etc/cron.d/librenms

# copy logrotate congfig
sudo cp /opt/librenms/misc/librenms.logrotate /etc/logrotate.d/librenms

# setting webui config.php
sudo cp /opt/librenms/config.php.default /opt/librenms/config.php

sudo sed -i "6c \$config['db_host'] = 'localhost';" /opt/librenms/config.php
sudo sed -i "7c \$config['db_user'] = '${dbuser}';" /opt/librenms/config.php
sudo sed -i "8c \$config['db_pass'] = '${dbpass}';" /opt/librenms/config.php
sudo sed -i "9c \$config['db_name'] = '${dbname}';" /opt/librenms/config.php

#change mode from librenms
sudo chmod 777 /opt
sudo chmod 777 /opt/librenms
sudo chmod 777 /opt/librenms/logs/librenms.log
sudo chown -R librenms:librenms /opt/librenms
sudo setfacl -d -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/
sudo chmod -R ug=rwX /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/:

# Transfer to influxdb
sudo echo "\$config['influxdb']['enable'] = true;" >> /opt/librenms/config.php
sudo echo "\$config['influxdb']['transport'] = 'http';" >> /opt/librenms/config.php  # Default, other options: https, udp
sudo echo "\$config['influxdb']['host'] = '127.0.0.1';" >> /opt/librenms/config.php
sudo echo "\$config['influxdb']['port'] = '8086';" >> /opt/librenms/config.php # http:8086 https:8088
sudo echo "\$config['influxdb']['db'] = '${dbname}';" >> /opt/librenms/config.php
sudo echo "\$config['influxdb']['username'] = '${dbuser}';" >> /opt/librenms/config.php
sudo echo "\$config['influxdb']['password'] = '${dbpass}';" >> /opt/librenms/config.php
sudo echo "\$config['influxdb']['timeout'] = 0;" >> /opt/librenms/config.php # Optional
sudo echo "\$config['influxdb']['verifySSL'] = false;" >> /opt/librenms/config.php # Optional

# final step
#sudo chown librenms:librenms /opt/librenms/config.php



# sql backup
sudo cat > /opt/sql_bk.sh <<EOF

sudo mysqldump -u root -p123456 ${dbname} > sqlbk_`date +"%Y-%m-%d"`.sql
#sudo mysql -h -u librenms -p 123456 ${dbname} < sqlbk_`date +"%Y-%m-%d"`.sql
EOF

sudo /opt/librenms/lnms migrate

sudo echo "*/10  *    * * *   root    /opt/sql_bk.sh" >> /etc/crontab

sudo /etc/init.d/cron restart

#修改config.json檔
#cd 
#cd Librenms_auto_build/auto_build/

#sudo chmod 777 ./config.json
#sudo sed -i "3c \"name\":\"${dbuser}\"," ./config.json
#sudo sed -i "7c \"user\":\"${uiuser}\"," ./config.json
#sudo sed -i "9c \"database\":\"${dbname}\"," ./config.json
#sudo chmod 777 Librenms_auto_build/auto_build/config.json
#sudo sed -i "3c \"name\":\"${dbuser}\"," Librenms_auto_build/auto_build/config.json
#sudo sed -i "7c \"user\":\"${uiuser}\"," Librenms_auto_build/auto_build/config.json
#sudo sed -i "9c \"database\":\"${dbname}\"," Librenms_auto_build/auto_build/config.json

#add user
sudo /opt/librenms/adduser.php ${uiuser} ${uipwd} 10 ${uiemail}

#add host 
ip=$(hostname -I)
lenth=${#ip}
ipnew=${ip:0:lenth-1}

sudo sed -i "33c \$config['snmp']['community'][] = \"${comm}\";" /opt/librenms/config.php
sudo sed -i "34c \$config['nets'][] = \"$ipnew/32\"; " /opt/librenms/config.php
#sudo sed -i "35c \$config['autodiscovery']['nets-exclude'][] = '$ipnew/32';" /opt/librenms/config.php
sudo sed -i "36c \$config['allow_duplicate_sysName'] = true; " /opt/librenms/config.php
sudo sed -i "37c \$config['discovery_by_ip'] = true; " /opt/librenms/config.php
sudo sed -i "38c \$config['discovery_modules']['discover-arp'] = true; " /opt/librenms/config.php
#/opt/librenms/snmp-scan.py

echo ==================== Grafana Built =======================
sudo git clone https://github.com/j13tw/School_Monitor_System.git /home/pi/School_Monitor_System
#sudo sed -i "11a csip = $cs" /home/pi/School_Monitor_System/Client/client.conf
sudo sed -i "3c command=python3 selfCheck.py $comm $cs $sip" /home/pi/School_Monitor_System/Client/client.conf 
sudo python3 /home/pi/School_Monitor_System/Client/raspi-4-buster/environment.py
#sudo python3 /home/pi/Librenms_auto_build/Client/environment.py
#sudo nohup python3 -u /home/pi/Librenms_auto_build/Client/selfCheck.py ${sn} > /home/pi/client.log 2>&1 &


echo ==================== Install Complete ====================
echo
echo "請於瀏覽器輸入IP"
# rrd back up
#sudo chmod 777 /opt/librenms/extra_code/rrdtool_dump.sh
#sudo chmod 777 /opt/librenms/extra_code/sql_upload.sh
#sudo mkdir /opt/librenms/extra_code/xml && sudo chmod 777 /opt/librenms/extra_code/xml

#sudo echo "0  *    * * *   root    /opt/librenms/extra_code/rrdtool_dump.sh" >> /etc/crontab
#sudo echo "*/10  *    * * *   root    /opt/librenms/extra_code/sql_upload.sh" >> /etc/crontab

