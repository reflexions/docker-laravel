#!/bin/bash

if [ ! -f /var/run/application/setup-completed ]; then
    /setup.sh
fi

cd /var/www/application

if [ "$APPLICATION_ENV" == "staging" ]
then
	php artisan migrate:refresh --seed
else
	php artisan migrate
fi

# Set # of hard links to 1 to keep cron happy.
touch /etc/cron.d/php5 /var/spool/cron/crontabs/www-data /etc/crontab

# ensure permissions of laravel run-time caches
chown -R www-data.www-data /var/run/application/
find /var/run/application/ -type d | xargs chmod 775
find /var/run/application/ -type f | xargs chmod 664

# start processes
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf