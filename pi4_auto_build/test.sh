#!/bin/bash

#read -p "ip: " ip;
#echo $ip
#ip1= echo $ip | awk 'BEGIN {FS="."}; {print $1}'
#ip2= echo $ip | awk 'BEGIN {FS="."}; {print $2}'
#ip3= echo $ip | awk 'BEGIN {FS="."}; {print $3}'
#ip4= echo $ip | awk 'BEGIN {FS="."}; {print $4}'
#ips= "$ip1 $ip2 $ip3 $ip4"
#ips="-1 2 3 4"
#for i in $ips;
#do 
#	if [ (echo $i)  -lt 0 && (echo $i) -gt "255" ];then
#		echo false
#		break
#	else
#		echo true
#	fi
#done

function check_ip() 
{      
local IP=$1      VALID_CHECK=$(echo $cs|awk -F. '$1<=255&&$2<=255&&$3<=255&&$4<=255{print "yes"}')      
if echo $IP|grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" >/dev/null; then          
	if [ $VALID_CHECK == "yes" ]; then
     		echo "IP $IP  available!"      
		echo "your ip is: $IP"
		read -p  "y/n : " ANS
		if [ $ANS == "y" ];then
			return 0
		else
			return 1
		fi  
	else              
		echo "IP $IP not available!"              
		return 1          
	fi      
else          
	echo "IP format error!"          
	return 1      
fi   }   

while true; 
do      
	read -p "Please enter IP: " cs      
	check_ip $cs      [ $? -eq 0 ] && break
done

#echo ".............."
#echo $cs
