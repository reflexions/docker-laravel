# content-infrastructure

## Installation

1. Add the following repository to composer.json

        "repositories": [
            {
                "url": "https://github.com/reflexions/content-infrastructure.git",
                "type": "git"
            }
        ],

2. From the shell run composer to require the package

        composer require reflexions/content-infrastructure dev-master

3. Add the service provider to config/app.php

        'Reflexions\Content\Infrastructure\InfrastructureServiceProvider',
        
4. Change the Application class in bootstrap/app.php

        $app = new Reflexions\Content\Infrastructure\Application(
            realpath(__DIR__.'/../')
        );

5. Publish the Dockerfile into the project

        php artisan vendor:publish

## Configuration

Most laravel .env settings can be passed through *except* DB_HOST.  The container will consider itself to be localhost.  To connect to a database running locally but outside of docker use the IP address of the host system as set by the docker install:

* Kitematic: host is available via 192.168.99.1
* boot2docker: host is available via 192.168.59.3

## Usage

Build the image

        docker build -t application:v1 .

Run the image

        env $(cat .env | xargs) docker run \
            -e APP_DEBUG \
            -e DB_DATABASE \
            -e DB_HOST \
            -e DB_PASSWORD \
            -e DB_USERNAME \
            -e DEVELOPER_EMAIL \
            -p 80:80 \
            -v `pwd`:/var/www/application \
            -d application:v1

Attach a shell and inspect the image

        docker exec -it $(docker ps | grep application:v1 | awk '{print $1}') bash

## Cleanup

Remove exited containers

        docker rm -v $(docker ps -a -f status=exited -q)

Remove untagged images

        docker rmi $(docker images --no-trunc | grep "<none>" | awk '{print $3}')
