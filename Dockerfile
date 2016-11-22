FROM debian:jessie
EXPOSE 80
MAINTAINER "Reflexions" <docker-laravel@reflexions.co>

# default is 'dumb'. that cripples less, vim, coloring, etc
ENV TERM xterm-256color

# because I use ll all the time
COPY ./home/.bashrc /root/.bashrc

# ffmpeg not in debian:jessie
RUN echo deb http://www.deb-multimedia.org jessie main non-free >> /etc/apt/sources.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install deb-multimedia-keyring --force-yes --assume-yes \
    && apt-get -y upgrade

# openssl is a dependency of apache2, but just to be clear, we list it separately
# we use https urls for yarn, so we need apt-transport-https
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        apache2 \
        apt-transport-https \
        curl \
        git-core \
        locales \
        openssl \
        vim-tiny

# jessie has an old version of node (0.10.29). get version 6 (LTS) instead
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -

# laravel uses yarn, so let's get it
COPY ./yarn/yarn.list /etc/apt/sources.list.d/yarn.list
COPY ./yarn/pubkey.gpg /tmp/yarn-pubkey.gpg
RUN apt-key add /tmp/yarn-pubkey.gpg

RUN apt-get update \
    && apt-get install -y \
        yarn

# Configure locales
ENV LANGUAGE en_US.UTF-8
RUN echo "America/New_York" > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata \
    && locale-gen ${LANGUAGE} \
    && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

# Copy GTE CyberTrust Global Root certificate
# Needed for mailchimp because of https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=812708
COPY ./certs/gte_cybertrust_global_root.crt /etc/ssl/certs/gte_cybertrust_global_root.crt
RUN c_rehash /etc/ssl/certs # requires openssl

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        ffmpeg \
        imagemagick

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libapache2-mod-php5 \
        php-pear \
        php5 \
        php5-cli \
        php5-curl \
        php5-dev \
        php5-gd \
        php5-imagick \
        php5-mcrypt \
        php5-mysql \
        php5-pgsql \
        php5-redis \
        php5-sqlite \
    && a2enmod php5 \
    && a2enmod rewrite

# Configure php

# install composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# set timezone to Eastern
RUN sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ America\/New_York/g' /etc/php5/cli/php.ini \
    && sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ America\/New_York/g' /etc/php5/apache2/php.ini

# turn off persistent connections
RUN sed -i 's/mysql.allow_persistent = On/mysql.allow_persistent = Off/g' /etc/php5/cli/php.ini \
    && sed -i 's/mysql.allow_persistent = On/mysql.allow_persistent = Off/g' /etc/php5/apache2/php.ini \
    && sed -i 's/pgsql.allow_persistent = On/pgsql.allow_persistent = Off/g' /etc/php5/cli/php.ini \
    && sed -i 's/pgsql.allow_persistent = On/pgsql.allow_persistent = Off/g' /etc/php5/apache2/php.ini

# increase memory limit. cli gets more than apache.
RUN sed -i 's/memory_limit = 128M/memory_limit = 1G/g' /etc/php5/cli/php.ini \
    && sed -i 's/memory_limit = 128M/memory_limit = 256M/g' /etc/php5/apache2/php.ini

# allow bigger uploads
RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php5/apache2/php.ini \
    && sed -i 's/post_max_size = 8M/post_max_size = 200M/g' /etc/php5/apache2/php.ini

# safer sessions
RUN sed -i 's/session.use_strict_mode = 0/session.use_strict_mode = 1/g' /etc/php5/apache2/php.ini \
    && sed -i 's/session.cookie_httponly =/session.cookie_httponly = 1/g' /etc/php5/apache2/php.ini \
    && sed -i 's/session.hash_function = 0/session.hash_function = 1/g' /etc/php5/apache2/php.ini \
    && sed -i 's/session.hash_bits_per_character = 5/session.hash_bits_per_character = 6/g' /etc/php5/apache2/php.ini

# we're not running cron, so we have to gc sessions after requests
RUN sed -i 's/session.gc_probability = 0/session.gc_probability = 1/g' /etc/php5/apache2/php.ini

# enable opcache
RUN sed -i 's/;opcache.enable=0/opcache.enable=1/g' /etc/php5/apache2/php.ini

# start and setup scripts
# setup script runs on container startup to utilize GITHUB_TOKEN env variable
COPY . /usr/share/docker-laravel
RUN chmod 755 /usr/share/docker-laravel/bin/setup.sh /usr/share/docker-laravel/bin/start.sh
ENTRYPOINT ["/usr/share/docker-laravel/bin/start.sh"]

# Default ENV
# ------------------
ENV LARAVEL_WWW_PATH=/var/www/laravel \
    LARAVEL_RUN_PATH=/var/run/laravel \
    LARAVEL_STORAGE_PATH=/var/run/laravel/storage \
    LARAVEL_BOOTSTRAP_CACHE_PATH=/var/run/laravel/bootstrap/cache

WORKDIR /var/www/laravel
