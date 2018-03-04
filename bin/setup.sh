#!/usr/bin/env bash
set -x #echo on

# This script sets up OS-level config. This script is run by Dockerfile before the Project dir is copied over,
# so it doesn't expect app files to exist yet

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

# cache the github host key in case we have to connect with ssh
mkdir ~/.ssh/
chmod go-rwx ~/.ssh/
touch ~/.ssh/known_hosts
ssh-keyscan -H github.com | sort -u - ~/.ssh/known_hosts > ~/.ssh/tmp_hosts
mv ~/.ssh/tmp_hosts ~/.ssh/known_hosts

# configure composer
if [ "$GITHUB_TOKEN" != "Your_Github_Token" ]; then
    composer config --global github-oauth.github.com $GITHUB_TOKEN
    composer config --global repo.packagist composer https://packagist.org

    # not sure why the above isn't working, so lets also tell git about it
    GITHUB_USER=`curl -sH "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | grep '"login":' | cut -d'"' -f 4`
    git config --global credential.helper 'store'
    echo "https://$GITHUB_USER:$GITHUB_TOKEN@github.com" > ~/.git-credentials
    chmod go-rwx ~/.git-credentials
fi

# flag that setup has run
touch ${LARAVEL_RUN_PATH}/setup-completed

echo "-----------------------"
echo "END setup.sh"
echo "-----------------------"
