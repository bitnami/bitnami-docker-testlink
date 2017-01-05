[![CircleCI](https://circleci.com/gh/bitnami/bitnami-docker-testlink/tree/master.svg?style=shield)](https://circleci.com/gh/bitnami/bitnami-docker-testlink/tree/master)
[![Docker Hub Automated Build](http://container.checkforupdates.com/badges/bitnami/testlink)](https://hub.docker.com/r/bitnami/testlink/)

# What is TestLink?

> TestLink is a web-based test management system that facilitates software quality assurance. It is developed and maintained by Teamtest. The platform offers support for test cases, test suites, test plans, test projects and user management, as well as various reports and statistics.

https://testlink.org/

# TL;DR;

```bash
$ curl -LO https://raw.githubusercontent.com/bitnami/bitnami-docker-testlink/master/docker-compose.yml
$ docker-compose up
```

# Prerequisites

To run this application you need Docker Engine 1.10.0. Docker Compose is recommended with a version 1.6.0 or later.

# How to use this image

## Run TestLink with a Database Container

Running TestLink with a database server is the recommended way. You can either use docker-compose or run the containers manually.

### Run the application using Docker Compose

This is the recommended way to run TestLink. You can use the following docker compose template:

```yaml
version: '2'

services:
  mariadb:
    image: 'bitnami/mariadb:latest'
    volumes:
      - 'mariadb_data:/bitnami/mariadb'
  testlink:
    image: 'bitnami/testlink:latest'
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - 'testlink_data:/bitnami/testlink'
      - 'apache_data:/bitnami/apache'
    depends_on:
      - mariadb
    environment:
      TESTLINK_USERNAME: admin
      TESTLINK_PASSWORD: verysecretadminpassword
      TESTLINK_EMAIL: admin@example.com

volumes:
  mariadb_data:
    driver: local
  testlink_data:
    driver: local
  apache_data:
    driver: local
```

### Run the application manually

If you want to run the application manually instead of using docker-compose, these are the basic steps you need to run:

1. Create a new network for the application and the database:

  ```bash
  $ docker network create testlink-tier
  ```

2. Start a MariaDB database in the network generated:

  ```bash
  $ docker run -d --name mariadb --net=testlink-tier bitnami/mariadb
  ```

  *Note:* You need to give the container a name in order for TestLink to resolve the host

3. Run the TestLink container:

  ```bash
  $ docker run -d -p 80:80 --name testlink --net=testlink-tier bitnami/testlink
  ```

Then you can access your application at http://your-ip/

## Persisting your application

If you remove every container and volume all your data will be lost, and the next time you run the image the application will be reinitialized. To avoid this loss of data, you should mount a volume that will persist even after the container is removed.

For persistence of the TestLink deployment, the above examples define docker volumes namely `mariadb_data`, `testlink_data` and `apache_data`. The TestLink application state will persist as long as these volumes are not removed.

> **Note!** If you have already started using your application, follow the steps on [backing](#backing-up-your-application) up to pull the data from your running container down to your host.

### Mount host directories as data volumes with Docker Compose

This requires a minor change to the `docker-compose.yml` template previously shown:

```yaml
version: '2'

services:
  mariadb:
    image: 'bitnami/mariadb:latest'
    volumes:
      - '/path/to/mariadb-persistence:/bitnami/mariadb'
  testlink:
    image: 'bitnami/testlink:latest'
    depends_on:
      - mariadb
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - '/path/to/testlink-persistence:/bitnami/testlink'
      - '/path/to/apache-persistence:/bitnami/apache'
```

### Mount host directories as data volumes using the Docker command line

In this case you need to specify the directories to mount on the run command. The process is the same than the one previously shown:

1.  Create a network (if it does not exist):

  ```bash
  $ docker network create testlink-tier
  ```

2. Create a MariaDB container with host volume:

  ```bash
  $ docker run -d --name mariadb \
    --net testlink-tier \
    --volume /path/to/mariadb-persistence:/bitnami/mariadb \
    bitnami/mariadb:latest
  ```

  *Note:* You need to give the container a name in order for TestLink to resolve the host

3. Create the TestLink container with host volumes:

  ```bash
  $ docker run -d --name testlink -p 80:80 -p 443:443 \
    --net testlink-tier \
    --volume /path/to/testlink-persistence:/bitnami/testlink \
    --volume /path/to/apache-persistence:/bitnami/apache \
    --volume /path/to/php-persistence:/bitnami/php \
    bitnami/testlink:latest
  ```

# Upgrade this application

Bitnami provides up-to-date versions of MariaDB and TestLink, including security patches, soon after they are made upstream. We recommend that you follow these steps to upgrade your container. We will cover here the upgrade of the TestLink container. For the MariaDB upgrade see https://github.com/bitnami/bitnami-docker-mariadb/blob/master/README.md#upgrade-this-image

1. Get the updated images:

  ```bash
  $ docker pull bitnami/testlink:latest
  ```

2. Stop your container

 * For docker-compose: `$ docker-compose stop testlink`
 * For manual execution: `$ docker stop testlink`

3. (For non-compose execution only) Create a [backup](#backing-up-your-application) if you have not mounted the testlink folder in the host.

4. Remove the currently running container

 * For docker-compose: `$ docker-compose rm -v testlink`
 * For manual execution: `$ docker rm -v testlink`

5. Run the new image

 * For docker-compose: `$ docker-compose start testlink`
 * For manual execution ([mount](#mount-persistent-folders-manually) the directories if needed): `docker run --name testlink bitnami/testlink:latest`

# Configuration
## Environment variables
 When you start the testlink image, you can adjust the configuration of the instance by passing one or more environment variables either on the docker-compose file or on the docker run command line. If you want to add a new environment variable:

 * For docker-compose add the variable name and value under the application section:
```yaml
testlink:
  image: bitnami/testlink:latest
  ports:
    - 80:80
  environment:
    - TESTLINK_PASSWORD=my_password
```

 * For manual execution add a `-e` option with each variable and value:

```bash
 $ docker run -d -e TESTLINK_PASSWORD=my_password -p 80:80 --name testlink -v /your/local/path/bitnami/testlink:/bitnami/testlink --net=testlink-tier bitnami/testlink
```

Available variables:

 - `TESTLINK_USERNAME`: TestLink admin username. Default: **user**
 - `TESTLINK_PASSWORD`: TestLink admin password. Default: **bitnami**
 - `TESTLINK_EMAIL`: TestLink admin email. Default: **user@example.com**
 - `TESTLINK_LANGUAGE`: TestLink default language. Default: **en_US**
 - `MARIADB_USER`: Root user for the MariaDB database. Default: **root**
 - `MARIADB_PASSWORD`: Root password for the MariaDB.
 - `MARIADB_HOST`: Hostname for MariaDB server. Default: **mariadb**
 - `MARIADB_PORT`: Port used by MariaDB server. Default: **3306**

### SMTP Configuration

To configure TestLink to send email using SMTP you can set the following environment variables:

 - `SMTP_ENABLE`: Enable SMTP mail delivery.
 - `SMTP_HOST`: SMTP host.
 - `SMTP_PORT`: SMTP port.
 - `SMTP_USER`: SMTP account user.
 - `SMTP_PASSWORD`: SMTP account password.
 - `SMTP_CONNECTION_MODE`: SMTP connection mode, `ssl` or `tls`.

This would be an example of SMTP configuration using a GMail account:

 * docker-compose:

```yaml
  testlink:
    image: bitnami/testlink:latest
    ports:
      - '80:80'
    environment:
      - SMTP_ENABLE=true
      - SMTP_HOST=smtp.gmail.com
      - SMTP_PORT=587
      - SMTP_USER=your_email@gmail.com
      - SMTP_PASSWORD=your_password
      - SMTP_CONNECTION_MODE=tls
```

 * For manual execution:

```bash
 $ docker run -d -e SMTP_ENABLE=true -e SMTP_HOST=smtp.gmail.com -e SMTP_PORT=587 -e SMTP_USER=your_email@gmail.com -e SMTP_PASSWORD=your_password -e SMTP_CONNECTION_MODE=tls -p 80:80 --name testlink -v /your/local/path/bitnami/testlink:/bitnami/testlink --network=testlink-tier bitnami/testlink$ docker rm -v testlink
```

# Backing up your application

To backup your application data follow these steps:

1. Stop the running container:

  * For docker-compose: `$ docker-compose stop testlink`
  * For manual execution: `$ docker stop testlink`

2. Copy the TestLink data folder in the host:

  ```bash
  $ docker cp /your/local/path/bitnami:/bitnami/testlink
  ```

# Restoring a backup

To restore your application using backed up data simply mount the folder with TestLink data in the container. See [persisting your application](#persisting-your-application) section for more info.

# Contributing

We'd love for you to contribute to this container. You can request new features by creating an
[issue](https://github.com/bitnami/bitnami-docker-testlink/issues), or submit a
[pull request](https://github.com/bitnami/bitnami-docker-testlink/pulls) with your contribution.

# Issues

If you encountered a problem running this container, you can file an
[issue](https://github.com/bitnami/bitnami-docker-testlink/issues). For us to provide better support,
be sure to include the following information in your issue:

- Host OS and version
- Docker version (`$ docker version`)
- Output of `$ docker info`
- Version of this container (`$ echo $BITNAMI_IMAGE_VERSION` inside the container)
- The command you used to run the container, and any relevant output you saw (masking any sensitive
information)

# License

Copyright 2016 Bitnami

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
