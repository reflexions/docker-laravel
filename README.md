### reflexions/docker-laravel

- Only depends on the Docker Toolbox
- Edit with Sublime, PhpStorm, Eclipse, etc
- Installs everything necessary to get started - laravel, php, database
  - Can start with empty directory or existing laravel project
  - No need to install PHP via homebrew / MacPorts / .MSI / apt-get / yum / etc
- Addresses permissions errors without requiring `chmod 777`

#### Overview

- Runs setup script first time
- Downloads fresh laravel 5.2 if the _app_ directory is missing
- Adds dependency on `reflexions/docker-laravel` composer package
- Updates _bootstrap/app.php_ to use `Reflexions\DockerLaravel\DockerApplication` to prevent permissions errors

#### Instructions

1.) Install [Docker Toolbox](https://www.docker.com/docker-toolbox) to get docker, docker-compose, and the Kitematic GUI

2.) Create a _docker-compose.yml_ in the project directory.  Define the laravel service and any desired database services:

```yaml
laravel:
  image: reflexions/docker-laravel:latest
  ports:
    - 80:80
  env_file: .env
  links:
    - database
  volumes:
    - .:/var/www/laravel

database:
  image: postgres:9.4.4
  env_file: .env
  environment:
    LC_ALL: C.UTF-8
```

3.) Obtain a [Github Personal Access Token](https://github.com/settings/tokens/new).  Create an  _.env_ file in the project directory.  Configure laravel and other services as desired.  The `database` service above corresponds to `DB_HOST=database` below:

```bash
# laravel service
GITHUB_TOKEN=Your_Github_Token
APP_KEY=SomeRandomString
DB_CONNECTION=postgres
DB_HOST=database
DB_DATABASE=application
DB_USERNAME=username
DB_PASSWORD=password

# database service
POSTGRES_DB=application
POSTGRES_USER=username
POSTGRES_PASSWORD=password
```

4.) With one command download the images, create the service containers, and start the application:

```bash
docker-compose up
```

5.) (Optional) Single line to open bash shell suitable for running `composer` or `php artisan`:

```bash
docker exec -it $(docker ps | grep reflexions/docker-laravel | awk '{print $1}') bash
```

#### Front-end build systems

Front-end build systems (gulp, grunt, bower, etc) are best installed outside of docker.  The resulting assets will be readily accessible via the volume mapping defined on the laravel service.

#### Elastic Beanstalk

Add a _Dockerfile_ to the root of the project to deploy with Elastic Beanstalk:

```
FROM reflexions/docker-laravel:latest

MAINTAINER "Your Name" <your@email.com>

COPY . /var/www/laravel
WORKDIR /var/www/laravel

EXPOSE 80
ENTRYPOINT ["/usr/share/docker-laravel/bin/start.sh"]
```
