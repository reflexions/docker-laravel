#!/usr/bin/env bash
set -x #echo on

# This script configures composer to make sure it knows about laravel/laravel and reflexions/docker-laravel
# After it has been run once, rerunning it should have no effect.

echo "-----------------------"
echo "START new-project.sh"
echo "-----------------------"
cd /usr/share/docker-laravel

# install laravel if it hasn't been setup in the project dir yet
if [ ! -d "${LARAVEL_WWW_PATH}/app" ]; then
    cd ${LARAVEL_WWW_PATH}
    composer create-project --prefer-dist laravel/laravel /tmp/laravel
    rm /tmp/laravel/.env
    mv /tmp/laravel/* ${LARAVEL_WWW_PATH}
    mv /tmp/laravel/.???* ${LARAVEL_WWW_PATH}
    rm -Rf /tmp/laravel
    php artisan key:generate
    cd /usr/share/docker-laravel
fi

# run composer install if reflexions/docker-laravel hasn't been installed
if [ ! -d "${LARAVEL_WWW_PATH}/vendor/reflexions/docker-laravel" ]; then
    cd ${LARAVEL_WWW_PATH}
    composer install
    cd /usr/share/docker-laravel
fi
#  require reflexions/docker-laravel if it hasn't been added to composer yet
if [ ! -d "${LARAVEL_WWW_PATH}/vendor/reflexions/docker-laravel" ]; then
    cd ${LARAVEL_WWW_PATH}
    composer require reflexions/docker-laravel
    sed -i 's/Illuminate\\Foundation\\Application/Reflexions\\DockerLaravel\\DockerApplication/g' ${LARAVEL_WWW_PATH}/bootstrap/app.php
    cd /usr/share/docker-laravel
fi

echo "-----------------------"
echo "END new-project.sh"
echo "-----------------------"
