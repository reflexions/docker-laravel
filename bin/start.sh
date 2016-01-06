#!/bin/bash

if [ ! -f /var/run/laravel/setup-completed ]; then
    /usr/share/docker-laravel/bin/setup.sh
fi

cd /var/www/laravel

# reset permissions of laravel run-time caches
chown -R www-data.www-data /var/run/laravel/
find /var/run/laravel/ -type d | xargs chmod 775
find /var/run/laravel/ -type f | xargs chmod 664

# Set # of hard links to 1 to keep cron happy.
touch /etc/cron.d/php5 /var/spool/cron/crontabs/www-data /etc/crontab

# start processes
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf