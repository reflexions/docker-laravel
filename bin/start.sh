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

# check for the leader marker
# more info: http://manmakeweb.com/2016/03/29/transitioning-to-rails-docker-and-elastic-beanstalk/
# if the dir doesn't exist, we assume the check hasn't been implemented and that it's a single host
if [ ! -d /tmp/leader_check -o -f /tmp/leader_check/is_leader ]
then
    # ensure that the environment we're running in has had db updates applied
    if [ "$RUN_MIGRATE_FORCED" == 1 -o "${RUN_MIGRATE_FORCED,,}" == 'true' ] ; then
        php artisan migrate --force
    elif [ "$RUN_MIGRATE" == 1 -o "${RUN_MIGRATE,,}" == 'true' ] ; then
        php artisan migrate
    fi
else
    echo "Skipping database migrations. /tmp/leader_check exists, but we're not the leader"
fi

# start processes
echo "Starting Apache"
source /etc/apache2/envvars
exec /usr/sbin/apache2 -DFOREGROUND
