#!/bin/bash
set -x #echo on

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
if [ "$RUN_MIGRATE_FORCED" == 1 -o "${RUN_MIGRATE_FORCED,,}" == 'true' ] ; then
    php artisan migrate --force
elif [ "$RUN_MIGRATE" == 1 -o "${RUN_MIGRATE,,}" == 'true' ] ; then
    php artisan migrate
fi

# start processes
echo "Starting Apache"
source /etc/apache2/envvars
exec /usr/sbin/apache2 -DFOREGROUND
