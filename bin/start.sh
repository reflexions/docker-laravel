#!/bin/bash

if [ ! -f ${LARAVEL_RUN_PATH}/setup-completed ]; then
    /usr/share/docker-laravel/bin/setup.sh
fi

# reset permissions of laravel run-time caches
chown -R www-data.www-data ${LARAVEL_RUN_PATH}
find ${LARAVEL_RUN_PATH} -type d | xargs chmod 775
find ${LARAVEL_RUN_PATH} -type f | xargs chmod 664

# Set # of hard links to 1 to keep cron happy.
touch /etc/cron.d/php5 /var/spool/cron/crontabs/www-data /etc/crontab

cd ${LARAVEL_WWW_PATH}

# start processes
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf