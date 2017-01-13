#!/bin/bash
set -x #echo on

# this script is the main entrypoint. It starts the app at container startup.

if [ ! -f ${LARAVEL_RUN_PATH}/setup-completed ]; then
    echo "You are required to run /usr/share/docker-laravel/bin/setup.sh in your Dockerfile before the container starts"
    echo "Also, if you haven't installed laravel yet, run /usr/share/docker-laravel/bin/new-project.sh after setup.sh"
    exit 1
fi

# clear leftover pid files from interrupted containers
rm -f /var/run/apache2/apache2.pid

# reset permissions of laravel run-time caches
chown -R www-data:www-data ${LARAVEL_RUN_PATH}
find ${LARAVEL_RUN_PATH} -type d -print0 | xargs -0 chmod 775
find ${LARAVEL_RUN_PATH} -type f -print0 | xargs -0 chmod 664

cd ${LARAVEL_WWW_PATH}

# todo: lock the db while migrations run to prevent other instances from running migrate simultaneously
# beanstalk's leader_only isn't a guarantee, so maybe we use a db lock instead somehow?
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
