echo "-----------------------"
echo "START setup.sh"
echo "-----------------------"
cd /usr/share/docker-laravel

# application run dirs
mkdir ${LARAVEL_RUN_PATH}
chown -R www-data ${LARAVEL_RUN_PATH}
chmod -R 775 ${LARAVEL_RUN_PATH}

mkdir -p ${LARAVEL_STORAGE_PATH}
mkdir ${LARAVEL_STORAGE_PATH}/app
mkdir ${LARAVEL_STORAGE_PATH}/framework
mkdir ${LARAVEL_STORAGE_PATH}/framework/sessions
mkdir ${LARAVEL_STORAGE_PATH}/framework/views
mkdir ${LARAVEL_STORAGE_PATH}/framework/cache
mkdir ${LARAVEL_STORAGE_PATH}/logs
chown -R www-data ${LARAVEL_STORAGE_PATH}
chmod -R 775 ${LARAVEL_STORAGE_PATH}

mkdir -p ${LARAVEL_BOOTSTRAP_CACHE_PATH}
mkdir ${LARAVEL_BOOTSTRAP_CACHE_PATH}/cache
chown -R www-data ${LARAVEL_BOOTSTRAP_CACHE_PATH}
chmod -R 775 ${LARAVEL_BOOTSTRAP_CACHE_PATH}

# configure composer
if [ "$GITHUB_TOKEN" != "Your_Github_Token" ]; then
	composer config --global github-oauth.github.com $GITHUB_TOKEN
	composer config --global repo.packagist composer https://packagist.org
	composer install
fi

# configure apache
cp etc/apache2/sites-available/001-application.conf /etc/apache2/sites-available/001-application.conf
ln -s /etc/apache2/sites-available/001-application.conf /etc/apache2/sites-enabled/
unlink /etc/apache2/sites-enabled/000-default.conf

# maybe install laravel
if [ ! -d "${LARAVEL_WWW_PATH}/app" ]; then
	if [ "$GITHUB_TOKEN" == "Your_Github_Token" ]; then
		>&2 echo "Error: GITHUB_TOKEN not set."
		exit 1
	fi

	cd ${LARAVEL_WWW_PATH}
    composer create-project --prefer-dist laravel/laravel /tmp/laravel
    rm /tmp/laravel/.env
    mv /tmp/laravel/* ${LARAVEL_WWW_PATH}
    mv /tmp/laravel/.???* ${LARAVEL_WWW_PATH}
    rm -Rf /tmp/laravel
    php artisan key:generate
	cd /usr/share/docker-laravel
fi

# maybe composer install
if [ ! -d "${LARAVEL_WWW_PATH}/vendor" ]; then
	if [ "$GITHUB_TOKEN" == "Your_Github_Token" ]; then
		>&2 echo "Error: GITHUB_TOKEN not set."
		exit 1
	fi

	cd ${LARAVEL_WWW_PATH}
	composer install
fi

# maybe install reflexions/docker-laravel
#   - maybe it needs to be installed
if [ ! -d "${LARAVEL_WWW_PATH}/vendor/reflexions/docker-laravel" ]; then
	if [ "$GITHUB_TOKEN" == "Your_Github_Token" ]; then
		>&2 echo "Error: GITHUB_TOKEN not set."
		exit 1
	fi

	cd ${LARAVEL_WWW_PATH}
	composer install
	cd /usr/share/docker-laravel
fi
#   - or maybe it needs to be required
if [ ! -d "${LARAVEL_WWW_PATH}/vendor/reflexions/docker-laravel" ]; then
	if [ "$GITHUB_TOKEN" == "Your_Github_Token" ]; then
		>&2 echo "Error: GITHUB_TOKEN not set."
		exit 1
	fi

	cd ${LARAVEL_WWW_PATH}
	composer require reflexions/docker-laravel
	sed -i 's/Illuminate\\Foundation\\Application/Reflexions\\DockerLaravel\\DockerApplication/g' ${LARAVEL_WWW_PATH}/bootstrap/app.php
	cd /usr/share/docker-laravel
fi

# flag that setup has run
touch ${LARAVEL_RUN_PATH}/setup-completed

echo "-----------------------"
echo "END setup.sh"
echo "-----------------------"
