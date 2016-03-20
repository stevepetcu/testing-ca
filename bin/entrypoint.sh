#!/bin/bash

service mysql start
service rabbitmq-server start
service rsyslog start

go run cmd/rabbitmq-setup/main.go -server amqp://localhost

exec "$@"
