# docker-ubuntu-wildfly8.x
docker image for wildfly 8.x based on ubuntu linux

Commandline using docker command:

build:

    docker build -t ubuntu-wildfly8.x .

debug:

    docker run -it --entrypoint=bash ubuntu-wildfly8.x

run:

You can use the **docker** commands below or just trigger **docker-compose**:

    USER_ID=`id -u` docker-compose up -d

or the **docker** commmand:

    docker run -d -p 18080:8080 -p 19990:9990 -u `id -u` -v ~/git/docker-ubuntu-wildfly8.x/shared:/opt/shared --name wildfly8.x-instance ubuntu-wildfly8.x

after that use **docker logs -f wildfly8.x-instance**

login:

    docker exec -it -u jboss wildfly8.x-instance /bin/bash

logout:

    exit

for testing use this repo:

    https://github.com/xcoulon/wildfly-quickstart/tree/master/helloworld

    mvn clean package wildfly:deploy -Dwildfly.hostname=localhost -Dwildfly.port=19990

    curl -viL http://localhost:18080/wildfly-helloworld