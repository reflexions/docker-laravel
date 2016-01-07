### reflexions/docker-laravel

- Provides docker image with all necessary dependencies including a development database.
- Installs into a local project directory.  Edit with Sublime, PhpStorm, Eclipse, etc.
- Installs fresh laravel 5.2 if installed in empty directory.
- Installs `reflexions/docker-laravel` php package if added to existing laravel app.
- Installs `Reflexions\DockerLaravel\DockerApplication` into _bootstrap/app.php_ to prevent permissions errors.

#### Instructions

1.) Install [Docker Toolbox](https://www.docker.com/docker-toolbox) to get docker, docker-compose, and the Kitematic GUI

2.) In the project directory create _docker-compose.yml_ with these two services:

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

3.) Obtain a [Github Personal Access Token](https://github.com/settings/tokens/new).  In the project directory create an  _.env_ file to configure the laravel and database services:

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

4.) Start the services

```bash
docker-compose up
```

5.) (Optional) Shell into image

```bash
docker exec -it $(docker ps | grep reflexions/docker-laravel | awk '{print $1}') bash
```

#### Front-end build systems

Frontend build systems (gulp, grunt, bower, etc) are best installed outside of docker.  The resulting assets will be readily accessible via the volume mapping on the laravel service.

#### Elastic Beanstalk

Add a _Dockerfile_ to the root of the Laravel app to deploy with Elastic Beanstalk:

```
FROM reflexions/docker-laravel:latest

MAINTAINER "Your Name" <your@email.com>

COPY . /var/www/laravel
WORKDIR /var/www/laravel

EXPOSE 80
ENTRYPOINT ["/usr/share/docker-laravel/bin/start.sh"]
```
