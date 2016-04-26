#!/bin/bash

if [ ! -f ${LARAVEL_RUN_PATH}/setup-completed ]; then
    /usr/share/docker-laravel/bin/setup.sh
fi

# reset permissions of laravel run-time caches
chown -R www-data.www-data ${LARAVEL_RUN_PATH}
find ${LARAVEL_RUN_PATH} -type d -print0 | xargs -0 chmod 775
find ${LARAVEL_RUN_PATH} -type f -print0 | xargs -0 chmod 664

cd ${LARAVEL_WWW_PATH}

# clear leftover pid files from interrupted containers
rm -f /var/run/apache2/apache2.pid

# ensure that the environment we're running in has had db updates applied
php artisan migrate

# start processes
echo "Starting Apache"
source /etc/apache2/envvars
/usr/sbin/apache2 -DFOREGROUND
