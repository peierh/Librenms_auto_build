#!/bin/bash

cat> /home/work/grafana_setting/apikey.txt <<EOF



curl -X POST -H "Content-Type: application/json" -d '{"name":"apikeycurl", "role": "Admin"}' http://admin:admin@localhost:3000/api/auth/keys | sed -n 's|.*"key":"\([^"]*\)".*|\1|p'


EOF

#$api_key = 'test'

#echo api_key
	


