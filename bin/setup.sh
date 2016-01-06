echo "-----------------------"
echo "START setup.sh"
echo "-----------------------"
cd /usr/share/docker-laravel

# configure composer
composer config --global github-oauth.github.com $GITHUB_TOKEN
composer config --global repo.packagist composer https://packagist.org
composer install

# configure apache
cp etc/apache2/sites-available/001-application.conf /etc/apache2/sites-available/001-application.conf
ln -s /etc/apache2/sites-available/001-application.conf /etc/apache2/sites-enabled/
unlink /etc/apache2/sites-enabled/000-default.conf
    
# crontab
cp etc/crontab /var/spool/cron/crontabs/www-data
chown www-data.crontab /var/spool/cron/crontabs/www-data
chmod 0600 /var/spool/cron/crontabs/www-data

# supervisor
cp etc/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
cp etc/supervisor/conf.d/* /etc/supervisor/conf.d/
mkdir /var/run/laravel/logs/supervisor/

# maybe install laravel
if [ ! -f /var/www/laravel/app ]; then
	cd /var/www/laravel
    composer create-project --prefer-dist laravel/laravel /tmp/laravel
    rm /tmp/laravel/.env
    mv /tmp/laravel/* /var/www/laravel
    mv /tmp/laravel/.???* /var/www/laravel
    rm -Rf /tmp/laravel
    php artisan key:generate
	cd /usr/share/docker-laravel
fi

# maybe install reflexions/docker-laravel
if [ ! -f /var/www/laravel/vendor/reflexions/docker-laravel ]; then
	cd /var/www/laravel
	composer require reflexions/docker-laravel
	sed -i 's/Illuminate\\Foundation\\Application/Reflexions\\DockerLaravel\\DockerApplication/g' /var/www/laravel/bootstrap/app.php
	cd /usr/share/docker-laravel
fi

# flag that setup has run
touch /var/run/laravel/setup-completed

echo "-----------------------"
echo "END setup.sh"
echo "-----------------------"
