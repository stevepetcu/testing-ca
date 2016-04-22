#!/bin/bash

echo "127.0.0.1 boulder boulder-mysql boulder-rabbitmq" >> /etc/hosts

# replace mysql ports
sed -i 's/port\s*=\s*3306/port = '$BOULDER_MYSQL_PORT'/g' /etc/mysql/my.cnf
sed -i 's/:3306/:'$BOULDER_MYSQL_PORT'/g' test/boulder-config.json
sed -i 's/:3306/:'$BOULDER_MYSQL_PORT'/g' test/secrets/*

# replace rabbitmq ports
sed -i 's/:567[23]/:'$BOULDER_AMQP_PORT'/g' test/boulder-config.json
sed -i 's/:567[23]/:'$BOULDER_AMQP_PORT'/g' test/secrets/*
sed -i '/listenbuddy/i\\n    return' test/startservers.py

# replace boulder front port
sed -i 's/:4000/:'$BOULDER_PORT'/g' test/boulder-config.json
sed -i 's/4000/'$BOULDER_PORT'/g' test/startservers.py

# replace default callback port
sed -i 's/5002/'$BOULDER_CALLBACK_PORT'/g' test/boulder-config.json

export RABBITMQ_NODE_PORT=$BOULDER_AMQP_PORT
export RABBITMQ_DIST_PORT=$(($RABBITMQ_NODE_PORT + 2000))
export RABBITMQ_NODENAME=boulder

service mysql start
RABBITMQ_NODE_PORT=$BOULDER_AMQP_PORT RABBITMQ_DIST_PORT=5673 RABBITMQ_NODENAME=boulder rabbitmq-server -detached
service rsyslog start

go run cmd/rabbitmq-setup/main.go -server amqp://boulder-rabbitmq:$BOULDER_AMQP_PORT

exec "$@"
