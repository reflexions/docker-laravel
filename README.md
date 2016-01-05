# docker-laravel

## Installation into a laravel 5 project

1. Configure composer to use your [GitHub token](https://github.com/settings/tokens/new)

        composer config -g github-oauth.github.com YOUR-GITHUB-TOKEN-HERE

2. Install [Docker Toolbox](https://www.docker.com/docker-toolbox) to get docker, docker-compose, and the Kitematic GUI

3. Add the following repository to _composer.json_

```json
    "repositories": [
        {
            "url": "https://github.com/reflexions/docker-laravel.git",
            "type": "vcs"
        }
    ],
```

4. From the shell run composer to require the package

```bash
composer require --prefer-source reflexions/docker-laravel dev-master
```

5. Add the service provider to _config/app.php_

```php
        Reflexions\DockerLaravel\DockerServiceProvider::class,
```

6. Change the Application class in _bootstrap/app.php_

```php
$app = new Reflexions\DockerLaravel\DockerApplication(
    realpath(__DIR__.'/../')
);
```

7. Publish the _Dockerfile_, _docker-compose.yml_, and _example.env_ into the project

```bash
php artisan vendor:publish
```

8. Copy _example.env_ to _.env_.  Update the GITHUB_TOKEN along with the rest of the config.

```bash
mv example.env .env
```

```bash
GITHUB_TOKEN=your_github_token_here

APP_ENV=local
APP_DEBUG=true
APP_KEY=SomeRandomString
APP_STORAGE=/var/run/application

DB_HOST=postgres
DB_DATABASE=application
DB_USERNAME=laravel
DB_PASSWORD=password

# Match DB_USERNAME, DB_PASSWORD, and DB_DATABASE above
POSTGRES_DB=application
POSTGRES_USER=laravel
POSTGRES_PASSWORD=password

CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_DRIVER=sync

MAIL_DRIVER=smtp
MAIL_HOST=mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
```

9. Generate a secure key

```bash
$ php artisan key:generate
Application key [od6nnP2rPMobEXaP2vNBVBj9Hev000mG] set successfully.
```

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
