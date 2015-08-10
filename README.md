# content-infrastructure

## Installation into a laravel 5 project

1. Configure composer to use your [GitHub token](https://github.com/settings/tokens/new)

        composer config -g github-oauth.github.com YOUR-GITHUB-TOKEN-HERE

2. Add the GITHUB_TOKEN to your .env file along with the rest of your application's config

        APP_DEBUG=true
        DB_DATABASE=application
        DB_HOST=192.168.99.1
        DB_PASSWORD=password
        DB_USERNAME=username
        DEVELOPER_EMAIL=you@reflexions.co
        GITHUB_TOKEN=YOUR-GITHUB-TOKEN-HERE

2. Install [Kitematic](https://kitematic.com/) to get docker

3. Add the following repository to _composer.json_

        "repositories": [
            {
                "url": "https://github.com/reflexions/content-infrastructure.git",
                "type": "vcs"
            }
        ],

3. From the shell run composer to require the package

        composer require --prefer-source reflexions/content-infrastructure dev-master

4. Add the service provider to _config/app.php_

        'Reflexions\Content\Infrastructure\InfrastructureServiceProvider',
        
5. Change the Application class in _bootstrap/app.php_

        $app = new Reflexions\Content\Infrastructure\Application(
            realpath(__DIR__.'/../')
        );

6. Publish the _Dockerfile_ into the project

        php artisan vendor:publish

## Container Configuration

Most laravel .env settings will be the same *except* DB_HOST.  The container will consider itself to be localhost.  To connect to a database running locally but outside of docker use the IP address of the host system as set by the docker install:

* Kitematic: host is available via 192.168.99.1
* boot2docker: host is available via 192.168.59.3

Also the db needs to be configured appropriately to allow connections from the docker container:

* MySQL needs to be started with "--bind-address=0.0.0.0".  This may require editing the LaunchAgent plist file.
* MySQL permissions need to be granted to the appropriate subnet i.e. 

        GRANT ALL PRIVILEGES ON db_name.* TO 'username'@'192.168.99.%' IDENTIFIED BY 'password' WITH GRANT OPTION;

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
            -e GITHUB_TOKEN \
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
