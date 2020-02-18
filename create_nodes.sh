#!/bin/bash
set -x
WORKDIR='/opt/compose'
NODE_ORDER=2
GALERA_IP=192.168.3.2
GALERA2_IP=192.168.2.2
WEB_IP=$GALERA2_IP
MYSQL_HOST=$GALERA2_IP
MYSQL_USER=imperituroard
MYSQL_PASS=imperituroard
MYSQL_ROOT_PASSWORD=P@ssw0rd

cat > ./.env <<-EOF
NODE_ORDER=$NODE_ORDER
GALERA_IP=$GALERA_IP
GALERA2_IP=$GALERA2_IP
MYSQL_HOST=$MYSQL_HOST
MYSQL_USER=$MYSQL_USER
MYSQL_PASS=$MYSQL_PASS
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
EOF

mkdir -p ./mysql.conf.d
cat > ./mysql.conf.d/my.cnf <<-EOF
[server]
[mysqld]
[galera]
wsrep_on=ON
wsrep_provider="/usr/lib/galera/libgalera_smm.so"
wsrep_cluster_address="gcomm://${GALERA_IP},${GALERA2_IP}"
binlog_format=row
default_storage_engine=InnoDB
innodb_autoinc_lock_mode=2
innodb_locks_unsafe_for_binlog=1
query_cache_size=0
query_cache_type=0
wsrep-sst-method=rsync
bind-address=$MYSQL_HOST
[embedded]
[mariadb]
[mariadb-10.1]
EOF

mkdir -p ./docker-entrypoint-initdb.d
cat > ./docker-entrypoint-initdb.d/create.sql <<-EOF
CREATE DATABASE pdns character set utf8;
CREATE USER '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASS}';
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASS}';
GRANT ALL ON pdns.* TO '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASS}';
GRANT ALL ON pdns.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASS}';
FLUSH PRIVILEGES;
EOF

cat > ./git.sh <<-EOF
#!/bin/bash
## crontab exec this script every munutes
cd ${WORKDIR}/webcontent
git pull origin
EOF

chmod +x ./git.sh
echo "* * * * * ${WORKDIR}/git.sh" >> /var/spool/cron/root

docker-compose up -d

until docker exec db-${NODE_ORDER} mysql -u${MYSQL_USER} -p${MYSQL_PASS} -e "SELECT 1"
do
sleep 5
done

docker exec pdns-$NODE_ORDER pdnsutil add-record lab2.jelastic.team webapp-$NODE_ORDER A $WEB_IP

#docker exec pdns1 pdnsutil delete-rrset lab2.jelastic.team www1 A

