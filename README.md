Acme Testing CA
===============

Provide a Certificate Authority server for testing purpose.

Requirements
------------

- docker

Usage
-----

Hosted on Docker Hub: https://hub.docker.com/r/acmephp/testing-ca/

Start the boulder container in background.

```bash
docker run -d --net host acmephp/testing-ca
```

> By design, to test the domain, boulder will resolve the domain to 127.0.0.1,
and call the given URL `http://mydomain.com:5002/.well-known/acme-challenge/${TOKEN}`.
That's why, You **MUST** use the flag `--net host` to run the boulder container
in the same network than your application.

Configure your application to call the testing CA with the following endpoints

```yaml
endpoint: http://127.0.0.1:4000
agreement: http://boulder:4000/terms/v1
```

Customization
-------------

Because boulder uses a MySQL and RabbitMQ server and because boulder has to
run with option `--net host` you may run into a port conflict. You can customize
those ports with the following environment variables:

```
BOULDER_MYSQL_PORT=43306    # MySQL server
BOULDER_AMQP_PORT=45672     # RabbitMq server
BOULDER_PORT=4000           # Boulder front
BOULDER_CALLBACK_PORT=5002  # Application's challenge
BOULDER_IP=127.0.0.1        # Ip of Boulder server
```
