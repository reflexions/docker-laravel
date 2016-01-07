# reflexions/docker-laravel

- Provides laravel docker image.
- Installs fresh laravel 5.2 if added to empty directory.
- Installs `reflexions/docker-laravel` php package if added to existing laravel app.
- Installs `Reflexions\DockerLaravel\DockerApplication` into _bootstrap/app.php_ to prevent permissions errors.

## Instructions

1.) Install [Docker Toolbox](https://www.docker.com/docker-toolbox) to get docker, docker-compose, and the Kitematic GUI

2.) In the project directory create _docker-compose.yml_

```yaml
laravel:
  image: reflexions/docker-laravel:latest
  ports:
    - 80:80
  env_file: .env
  links:
    - postgres
  volumes:
    - .:/var/www/laravel

postgres:
  image: postgres:9.4.4
  env_file: .env
  environment:
    LC_ALL: C.UTF-8
```

3.) Obtain a [Github Personal Access Token](https://github.com/settings/tokens/new).  In the project directory create a laravel _.env_ file with the GITHUB_TOKEN

```bash
GITHUB_TOKEN=Your_Github_Token
APP_KEY=SomeRandomString

DB_DATABASE=application
DB_USERNAME=laravel
DB_PASSWORD=password

# Match DB_USERNAME, DB_PASSWORD, and DB_DATABASE above
POSTGRES_DB=application
POSTGRES_USER=laravel
POSTGRES_PASSWORD=password
```

4.) Start containers

```bash
docker-compose up
```

## Optional

### Shell into image

```bash
docker exec -it $(docker ps | grep reflexions/docker-laravel | awk '{print $1}') bash
```

### Add _Dockerfile_ in the root of your Laravel app to deploy as an Elastic Beanstalk docker application.

```
FROM reflexions/docker-laravel:latest

MAINTAINER "Your Name" <your@email.com>

COPY . /var/www/laravel
WORKDIR /var/www/laravel

EXPOSE 80
ENTRYPOINT ["/usr/share/docker-laravel/bin/start.sh"]
```
