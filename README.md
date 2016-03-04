### reflexions/docker-laravel

by [Reflexions](https://reflexions.co)

- Only depends on the Docker Toolbox
- Edit with Sublime, PhpStorm, Eclipse, etc
- Installs everything necessary to get started - laravel, php, database
  - Can start with empty directory or existing laravel project
  - No need to install PHP via homebrew / MacPorts / .MSI / apt-get / yum / etc
- Addresses permissions errors without requiring `chmod 777`

#### Instructions

1.) Install [Docker Toolbox](https://www.docker.com/docker-toolbox) to get docker, docker-compose, and the Kitematic GUI.  Open a terminal with the docker env variables via `Kitematic -> File -> Open Docker Command Line Terminal`

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
DB_CONNECTION=pgsql
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

5.) (optional) APP_KEY

```bash
$ docker exec -it $(docker ps | grep reflexions/docker-laravel | awk '{print $1}') bash
root@4c0491540409:/var/www/laravel# php artisan key:generate
```

6.) (optional) Tinker

```bash
$ docker exec -it $(docker ps | grep reflexions/docker-laravel | awk '{print $1}') bash
root@4c0491540409:/var/www/laravel# php artisan tinker
```

#### Overview

- Runs setup script first time
- Uses github token to avoid composer rate limit errors
- Downloads fresh laravel 5.2 if the _app_ directory is missing
- Adds dependency on `reflexions/docker-laravel` composer package
- Updates _bootstrap/app.php_ to use `Reflexions\DockerLaravel\DockerApplication` to prevent permissions errors


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

This will define an application container.  Use RDS to create the database.  Add all variables from the _.env_ file (including the APP_KEY, DB_HOST, etc) into the `AWS Management Console`  -> `Elastic Beanstalk` -> `Your-Environment` -> `Configuration` -> `Software Configuration`.

#### Troubleshooting

##### **Problem:** Mac OS X: Couldn't connect to docker daemon
```bash
$ docker-compose up
ERROR: Couldn't connect to Docker daemon - you might need to run `docker-machine start default`.
$
```
_**Solution:**_ Open terminal with `Kitematic -> File -> Open Docker Command Line Terminal`.

##### **Problem:** Don't like the Docker Command Line Terminal

_**Solution:**_ Run `Kitematic -> Install Docker Commands`.  Then add the following line _~/.bash_profile_:
```bash
eval "$(docker-machine env dev)"
```

##### **Problem:** Changes to _.env_ file apparently ignored by laravel

_**Solution:**_ Restart cluster.  Settings in the _.env_ file are only read on start.
```bash
$ docker-compose restart
```

##### **Problem:** Mac OS X: Illegal Instruction 4
```bash
$ docker-compose up
Illegal instruction: 4
$
```

_**Solution:**_ Known issue with the Docker Toolbox on older CPUs.  Install docker-compose using pip

##### **Problem:** Can't connect to database

_**Solution:**_
  - Check that the DB_CONNECTION corresponds to the correct laravel db driver
  - Check that the DB_HOST corresponds to the name of the service listed in docker-compose.yml (i.e. "database" in the example above)

##### **Problem:** RuntimeException: No supported encrypter found. The cipher and / or key length are invalid.

_**Solution:**_

  - Run `php artisan key:generate` to update APP_KEY on .env, then restart the container.

##### **Problem:** Want to use mysql instead of postgres

_**Solution:**_
  - Modify `docker-config.yml` to reference MySQL:
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
  image: mysql:5.6
  env_file: .env
  environment:
    LC_ALL: C.UTF-8
```
  - Modify `.env` to reference MySQL:
```bash
# laravel service
GITHUB_TOKEN=Your_Github_Token
APP_KEY=SomeRandomString
DB_CONNECTION=mysql
DB_HOST=database
DB_DATABASE=application
DB_USERNAME=username
DB_PASSWORD=password

# database service
MYSQL_DATABASE=application
MYSQL_USER=username
MYSQL_PASSWORD=password
```

##### **Problem:** Want to use mysql already running on local machine (not docker)

_**Solution:**_
  - Modify `docker-config.yml` to drop the unnecessary database service:
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
```
  - Modify `.env` to connect to MySQL via the docker-machine host ip address (192.168.99.1):
```bash
# laravel service
GITHUB_TOKEN=Your_Github_Token
APP_KEY=SomeRandomString
DB_CONNECTION=pgsql
DB_HOST=192.168.99.1
DB_DATABASE=application
DB_USERNAME=username
DB_PASSWORD=password
```
  - Ensure that "bind_address" config parameter is set to 0.0.0.0 on startup.  This can be set by your `my.cnf`, or it can be hard coded in your startup script.  To check the value use this sql:
```sql
show variables like 'bind_address';
```
  - Ensure that the database username has permission to connect from the docker container (usually 192.168.99.100)
```sql
CREATE USER 'username'@'192.168.99.100' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON application.* TO 'username'@'192.168.99.100';
FLUSH PRIVILEGES;
```
