FROM golang:1.5

# Install dependencies packages
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libltdl-dev \
        mariadb-server \
        rabbitmq-server \
        mariadb-client-core-10.0 \
        nodejs \
        rsyslog \

 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 4000

RUN go get github.com/jsha/listenbuddy
RUN go get bitbucket.org/liamstask/goose/cmd/goose
RUN go get -v github.com/golang/lint/golint

ENV BOULDER_CONFIG /go/src/github.com/letsencrypt/boulder/test/boulder-config.json
ENV GOPATH /go/src/github.com/letsencrypt/boulder/Godeps/_workspace:$GOPATH

RUN mkdir -p /go/src/github.com/letsencrypt \
 && git clone --depth 1 --branch master https://github.com/letsencrypt/boulder.git /go/src/github.com/letsencrypt/boulder

WORKDIR /go/src/github.com/letsencrypt/boulder

# Warmup
RUN service mysql start \
 && service rabbitmq-server start \
 && service rsyslog start \

 && test/create_db.sh \
 && GOBIN=/go/src/github.com/letsencrypt/boulder/bin go install  ./... \

 && service rsyslog stop \
 && service mysql stop \
 && service rabbitmq-server stop

COPY bin/entrypoint.sh /usr/bin
COPY config/rate-limit-policies.yml /go/src/github.com/letsencrypt/boulder/test

ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]
CMD [ "./start.py" ]
