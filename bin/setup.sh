echo "-----------------------"
echo "START setup.sh"
echo "-----------------------"
cd /var/www/application

# configure composer
composer config --global github-oauth.github.com $GITHUB_TOKEN
composer config --global repo.packagist composer https://packagist.org
composer install

# configure apache
cp vendor/reflexions/docker-laravel/etc/apache2/sites-available/001-application.conf /etc/apache2/sites-available/001-application.conf
ln -s /etc/apache2/sites-available/001-application.conf /etc/apache2/sites-enabled/
unlink /etc/apache2/sites-enabled/000-default.conf
    
# crontab
cp vendor/reflexions/docker-laravel/etc/crontab /var/spool/cron/crontabs/www-data
chown www-data.crontab /var/spool/cron/crontabs/www-data
chmod 0600 /var/spool/cron/crontabs/www-data

# supervisor
cp vendor/reflexions/docker-laravel/etc/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
cp vendor/reflexions/docker-laravel/etc/supervisor/conf.d/* /etc/supervisor/conf.d/
mkdir /var/run/application/logs/supervisor/

# flag that setup has run
touch /var/run/application/setup-completed
echo "-----------------------"
echo "END setup.sh"
echo "-----------------------"
