#!/bin/bash

if [ ! -f ${LARAVEL_RUN_PATH}/setup-completed ]; then
    /usr/share/docker-laravel/bin/setup.sh
fi

# reset permissions of laravel run-time caches
chown -R www-data.www-data ${LARAVEL_RUN_PATH}
find ${LARAVEL_RUN_PATH} -type d | xargs chmod 775
find ${LARAVEL_RUN_PATH} -type f | xargs chmod 664

cd ${LARAVEL_WWW_PATH}

# clear leftover pid files from interrupted containers
rm -f /var/run/apache2/apache2.pid

# start processes
exec /bin/bash -c "source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND"
