FROM debian:jessie

MAINTAINER "Reflexions" <docker-laravel@reflexions.co>

WORKDIR /tmp

# because I use ll all the time
COPY ./home/.bashrc /root/.bashrc

# ffmpeg not in debian:jessie
RUN echo deb http://www.deb-multimedia.org jessie main non-free >> /etc/apt/sources.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install deb-multimedia-keyring --force-yes --assume-yes \
    && apt-get clean

# openssl is a dependency of apache2, but just to be clear, we list it separately
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        apache2 \
        openssl \
        curl \
        locales \
        git-core \
    && apt-get clean

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
        imagemagick \
    && apt-get clean

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
    && apt-get clean \
    && a2enmod php5 \
    && a2enmod rewrite

# Configure php
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer
RUN sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ America\/New_York/g' /etc/php5/cli/php.ini
RUN sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ America\/New_York/g' /etc/php5/apache2/php.ini

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
EXPOSE 80
