#!/bin/bash
read -p "school number: " sn;

dbuser=lib${sn}user
dbpass=lib${sn}pass
dbname=lib${sn}name

service influxdb restart
sleep 5
curl -i -G "http://localhost:8086/query" --data-urlencode "q=CREATE database ${dbname}"
curl -i -G "http://localhost:8086/query" --data-urlencode "q=CREATE user ${dbuser} with password '${dbpass}'"
curl -i -G "http://localhost:8086/query" --data-urlencode "q=grant all PRIVILEGES TO ${dbuser}"
curl -i -G "http://localhost:8086/query" --data-urlencode "q=GRANT ALL ON ${dbname} TO ${dbuser}"

