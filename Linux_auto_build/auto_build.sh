#!/bin/bash

# setup install log placement
logPath="/tmp/client.log"
echo "--> Installation export to >> $logPath"
echo "--> Get install log by using \"tail -f " $logPath "\""
echo 
echo ==================== 安裝開始 ====================

# change timezon
sudo cp /usr/share/zoneinfo/Asia/Taipei /etc/localtime >> $logPath 2>&1
#
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

#
#read -p "請輸入IP： " cs;
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
sudo sed -i "3c \"name\":\"${dbuser}\"," Librenms_auto_build/auto_build/config.json >> $logPath 2>&1
sudo sed -i "7c \"user\":\"${uiuser}\"," Librenms_auto_build/auto_build/config.json >> $logPath  2>&1
sudo sed -i "9c \"database\":\"${dbname}\"," Librenms_auto_build/auto_build/config.json >> $logPath 2>&1

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

sudo apt-get update >> $logPath

# install packages
echo
echo ==================== Step1: 下載並安裝必要套件 ===================
echo 作業系統更新
echo "$(date '+%Y-%m-%d %H:%M:%S')    apt update" >> $logPath
sudo apt-get update >> $logPath

echo 安裝必要套件
echo "$(date '+%Y-%m-%d %H:%M:%S')    add-apt-repository ppa:ondrej/php" >> $logPath
sudo add-apt-repository ppa:ondrej/php -y >> $logPath
sudo apt-get update >> $logPath

echo 安裝php
echo "$(date '+%Y-%m-%d %H:%M:%S')    apt install php7.2" >> $logPath
sudo apt-get install php7.2 -y >>  $logPath

echo 安裝influxdb
echo "$(date '+%Y-%m-%d %H:%M:%S')    apt install influxdb" >> $logPath
sudo apt-get install influxdb influxdb-client -y >> $logPath

echo 安裝python相關套件
echo "$(date '+%Y-%m-%d %H:%M:%S')    apt install python3" >> $logPath
sudo apt-get install python3 python3-pip python3-dev -y >> $logPath

echo 安裝其他必要套件
echo "$(date '+%Y-%m-%d %H:%M:%S')    apt install other packages" >> $logPath
sudo apt-get install vim curl apache2 composer acl fping git graphviz imagemagick libapache2-mod-php7.2 mariadb-client mariadb-server mtr-tiny nmap php7.2-cli php7.2-curl php7.2-gd php7.2-json php7.2-mbstring php7.2-mysql php7.2-snmp php7.2-xml php7.2-zip python-memcache python-mysqldb rrdtool snmp snmpd whois -y >> $logPath

# add librenms user
echo 新增 librenms 使用者
echo "$(date '+%Y-%m-%d %H:%M:%S')    add librenms user" >> $logPath
sudo useradd librenms -d /opt/librenms -M -r >> $logPath
sudo usermod -a -G librenms www-data >> $logPath

echo ============================================ 下載 librenms ===========================================
sudo chmod 777 /opt
cd /opt
echo 下載 librenms
echo "$(date '+%Y-%m-%d %H:%M:%S')    git clone NMS" >> $logPath
sudo git clone https://github.com/andy212130/librenms.git >> $logPath
echo ===========================================================
cd /opt/librenms
sudo git checkout 1_62 >> $logPath
cd /opt
# set permissions
echo 挑整 librenms 權限
echo "$(date '+%Y-%m-%d %H:%M:%S')    set permissions" >> $logPath
sudo chown -R librenms:librenms /opt/librenms >> $logPath
sudo chmod 777 /opt/librenms >> $logPath
sudo setfacl -d -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/ >> $logPath
sudo setfacl -R -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/ >> $logPath

# install librenms
echo
echo ==================== Step2: 安裝 LibreNMS  ====================
cd /opt/librenms
echo 開始安裝 LibreNMS，請稍後
echo "$(date '+%Y-%m-%d %H:%M:%S')    LibreNMS installation" >> $logPath
sudo ./scripts/composer_wrapper.php self-update --1  >> $logPath 2>&1
sudo ./scripts/composer_wrapper.php install --no-dev >> $logPath 2>&1
# configure mysql
echo
echo ==================== Step3: 設定資料庫  ====================
sudo systemctl restart mysql >> $logPath
echo 設定資料庫權限
echo "$(date '+%Y-%m-%d %H:%M:%S')    DB setup" >> $logPath
sudo mysql --user="$root" --password=" "  --execute="CREATE DATABASE ${dbname} CHARACTER SET utf8 COLLATE utf8_unicode_ci;" >> $logPath
sudo mysql --user="$root" --password=" "  --execute="CREATE USER '${dbuser}'@'%' IDENTIFIED BY '${dbpass}';" >> $logPath
sudo mysql --user="$root" --password=" "  --execute="GRANT ALL PRIVILEGES ON ${dbname}.* TO '${dbuser}'@'%';" >> $logPath
sudo mysql --user="$root" --password=" "  --execute="FLUSH PRIVILEGES;" >> $logPath
sudo sed -i "13c innodb_file_per_table=1" /etc/mysql/mariadb.conf.d/50-server.cnf >> $logPath 2>&1
sudo sed -i "13a lower_case_table_names=0" /etc/mysql/mariadb.conf.d/50-server.cnf >> $logPath 2>&1
sudo sed -i "31c #bind-address       = 127.0.0.1" /etc/mysql/mariadb.conf.d/50-server.cnf >> $logPath 2>&1
sudo systemctl restart mysql >> $logPath

# configure php
echo 設定php
echo "$(date '+%Y-%m-%d %H:%M:%S')    configure php" >> $logPath
sudo sed -i "941c date.timezone = "Asia/Taipei"" /etc/php/7.2/apache2/php.ini >> $logPath 2>&1
sudo sed -i "941c date.timezone = "Asia/Taipei"" /etc/php/7.2/cli/php.ini >> $logPath 2>&1

sudo a2enmod php7.2 >> $logPath
sudo a2dismod mpm_event >> $logPath
sudo a2enmod mpm_prefork >> $logPath

echo 設定apache
echo "$(date '+%Y-%m-%d %H:%M:%S')    configure apache" >> $logPath
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

sudo a2dissite 000-default >> $logPath
sudo a2ensite librenms.conf >> $logPath
sudo a2enmod rewrite >> $logPath
sudo systemctl restart apache2 >> $logPath

# configure snmp
echo 設定snmp
echo "$(date '+%Y-%m-%d %H:%M:%S')    configure snmp" >> $logPath
sudo cp /opt/librenms/snmpd.conf.example /etc/snmp/snmpd.conf >> $logPath
sudo sed -i "2c com2sec readonly  default        ${comm} # RANDOMSTRINGGOESHERE" /etc/snmp/snmpd.conf >> $logPath
sudo curl -o /usr/bin/distro https://raw.githubusercontent.com/librenms/librenms-agent/master/snmp/distro >> $logPath
sudo chmod +x /usr/bin/distro >> $logPath
sudo systemctl restart snmpd >> $logPath

# cron job
echo 設定系統例行性工作
echo "$(date '+%Y-%m-%d %H:%M:%S')    cron job" >> $logPath
sudo cp /opt/librenms/librenms.nonroot.cron /etc/cron.d/librenms >> $logPath
sudo bash -c '(echo "0 0 5 * * root [ -f \"/home/$(logname)/client.log.1\" ] && rm /home/$(logname)/client.log.*" >> /etc/crontab)'

# copy logrotate congfig
echo "$(date '+%Y-%m-%d %H:%M:%S')    copy logrotate congfig" >> $logPath
sudo cp /opt/librenms/misc/librenms.logrotate /etc/logrotate.d/librenms >> $logPath

# setting webui config.php
echo "$(date '+%Y-%m-%d %H:%M:%S')    setting webui config.php" >> $logPath
sudo cp /opt/librenms/config.php.default /opt/librenms/config.php >> $logPath

sudo sed -i "6c \$config['db_host'] = 'localhost';" /opt/librenms/config.php >> $logPath
sudo sed -i "7c \$config['db_user'] = '${dbuser}';" /opt/librenms/config.php >> $logPath
sudo sed -i "8c \$config['db_pass'] = '${dbpass}';" /opt/librenms/config.php >> $logPath
sudo sed -i "9c \$config['db_name'] = '${dbname}';" /opt/librenms/config.php >> $logPath

#change mode from librenms
echo "$(date '+%Y-%m-%d %H:%M:%S')    change mode from librenms" >> $logPath
sudo chmod 777 /opt >> $logPath
sudo chmod 777 /opt/librenms >> $logPath
sudo chmod 777 /opt/librenms/logs/librenms.log >> $logPath 2>&1
sudo chown -R librenms:librenms /opt/librenms >> $logPath 2>&1
sudo setfacl -d -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/ >> $logPath 2>&1
sudo chmod -R ug=rwX /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/ >> $logPath 2>&1

# Transfer to influxdb
echo 設定 influxdb
echo "$(date '+%Y-%m-%d %H:%M:%S')    Transfer to influxdb" >> $logPath
sudo echo "\$config['influxdb']['enable'] = true;" >> /opt/librenms/config.php >> $logPath
sudo echo "\$config['influxdb']['transport'] = 'http';" >> /opt/librenms/config.php  >> $logPath # Default, other options: https, udp
sudo echo "\$config['influxdb']['host'] = '127.0.0.1';" >> /opt/librenms/config.php >> $logPath
sudo echo "\$config['influxdb']['port'] = '8086';" >> /opt/librenms/config.php >> $logPath # http:8086 https:8088
sudo echo "\$config['influxdb']['db'] = '${dbname}';" >> /opt/librenms/config.php >> $logPath
sudo echo "\$config['influxdb']['username'] = '${dbuser}';" >> /opt/librenms/config.php >> $logPath
sudo echo "\$config['influxdb']['password'] = '${dbpass}';" >> /opt/librenms/config.php >> $logPath
sudo echo "\$config['influxdb']['timeout'] = 0;" >> /opt/librenms/config.php >> $logPath # Optional
sudo echo "\$config['influxdb']['verifySSL'] = false;" >> /opt/librenms/config.php >> $logPath # Optional

# sql backup
sudo cat > /opt/sql_bk.sh <<EOF
#!/bin/bash

sudo mysqldump -u root -p123456 ${dbname} > sqlbk_`date +"%Y-%m-%d"`.sql
EOF

sudo /opt/librenms/lnms migrate

sudo echo "*/10  *    * * *   root    /opt/sql_bk.sh" >> /etc/crontab

sudo /etc/init.d/cron restart >> $logPath

#add user
echo 新增 librenms 使用者
sudo /opt/librenms/adduser.php ${uiuser} ${uipwd} 10 ${uiemail}  >> $logPath

sudo sed -i "33c \$config['snmp']['community'][] = \"${comm}\";" /opt/librenms/config.php >> $logPath
sudo sed -i "36c \$config['allow_duplicate_sysName'] = true; " /opt/librenms/config.php >> $logPath
sudo sed -i "37c \$config['discovery_by_ip'] = true; " /opt/librenms/config.php >> $logPath
sudo sed -i "38c \$config['discovery_modules']['discover-arp'] = true; " /opt/librenms/config.php >> $logPath
#/opt/librenms/snmp-scan.py

echo ==================== 安裝雲端同步專案功能 =======================
echo 下載雲端同步專案
sudo git clone https://github.com/j13tw/School_Monitor_System.git /home/ubuntu/School_Monitor_System  >> $logPath
sudo sed -i "3c command=python3 selfCheck.py $comm $cs $sip" /home/ubuntu/School_Monitor_System/Client/x86_PC/client.conf  >> $logPath
echo 執行雲端同步專案安裝，請稍後
sudo python3 /home/ubuntu/School_Monitor_System/Client/x86_PC/environment.py >> $logPath 2>&1


echo ==================== 安裝完成 ====================
echo
echo "請於瀏覽器輸入IP"
