docker run \
  --name mariadb-two \
  --network host \
  -v /opt/compose/mysql.conf.d:/etc/mysql/conf.d \
  -v /opt/compose/data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=P@ssw0rd \
  -p 3306:3306 \
  -p 4567:4567/udp \
  -p 4567-4568:4567-4568 \
  -p 4444:4444 \
  mariadb:10.1 \
  --wsrep_node_address=192.168.2.2
