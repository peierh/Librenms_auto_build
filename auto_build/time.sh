#!/bin/bash

sudo cat > /opt/sql_bk.sh <<EOF
#!/bin/bash

sudo mysqldump -u root -p123456 ${dbname} > sqlbk_`date +"%Y-%m-%d"`.sql
sudo mysql -h -u librenms -p 123456 ${dbname} < sqlbk_`date +"%Y-%m-%d"`.sql
EOF

