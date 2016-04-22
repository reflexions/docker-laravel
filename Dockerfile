FROM debian:jessie

MAINTAINER "Reflexions" <docker-laravel@reflexions.co>

WORKDIR /tmp
ENV LANGUAGE en_US.UTF-8

# ffmpeg not in debian:jessie
RUN echo deb http://www.deb-multimedia.org jessie main non-free >> /etc/apt/sources.list && \
    apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install deb-multimedia-keyring --force-yes --assume-yes && \
    apt-get clean

# Install packages
# Split into steps to minimize impact of mirror errors
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
		apache2 							\
        curl 								\
        locales 							\
	    git-core                            \
	    wget && \
	apt-get clean

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
		ffmpeg && \
    apt-get clean

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
	    imagemagick && \
    apt-get clean

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
		libapache2-mod-php5 				\
	    php-pear 							\
	    php5 								\
	    php5-cli 							\
	    php5-curl							\
	    php5-dev							\
	    php5-gd								\
	    php5-imagick                        \
	    php5-mcrypt							\
	    php5-mysql							\
	    php5-pgsql 							\
	    php5-redis 							\
	    php5-sqlite && \
    apt-get clean

# Configure apache2
RUN a2enmod php5 && \
	a2enmod rewrite

# Configure locales
RUN echo "America/New_York" > /etc/timezone && \
	dpkg-reconfigure -f noninteractive tzdata && \
	locale-gen ${LANGUAGE} && \
	DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

# Configure php
RUN curl -sS https://getcomposer.org/installer | php && \
	mv composer.phar /usr/local/bin/composer
RUN sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ America\/New_York/g' /etc/php5/cli/php.ini
RUN sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ America\/New_York/g' /etc/php5/apache2/php.ini

# Copy GTE CyberTrust Global Root certificate
COPY ./certs/gte_cybertrust_global_root.crt /etc/ssl/certs/gte_cybertrust_global_root.crt
RUN c_rehash /etc/ssl/certs

# start and setup scripts
# setup script runs on container startup to utilize GITHUB_TOKEN env variable
COPY . /usr/share/docker-laravel
RUN chmod 755 /usr/share/docker-laravel/bin/setup.sh /usr/share/docker-laravel/bin/start.sh
ENTRYPOINT ["/usr/share/docker-laravel/bin/start.sh"]

# Default ENV
# ------------------
ENV LARAVEL_WWW_PATH /var/www/laravel
ENV LARAVEL_RUN_PATH /var/run/laravel
ENV LARAVEL_STORAGE_PATH /var/run/laravel/storage
ENV LARAVEL_BOOTSTRAP_CACHE_PATH /var/run/laravel/bootstrap/cache
ENV GITHUB_TOKEN Your_Github_Token

ENV APP_ENV local
ENV APP_DEBUG true
ENV APP_KEY SomeRandomString

ENV DB_CONNECTION pgsql
ENV DB_HOST database
ENV DB_DATABASE application
ENV DB_USERNAME username
ENV DB_PASSWORD password

ENV CACHE_DRIVER file
ENV SESSION_DRIVER file
ENV QUEUE_DRIVER sync

ENV MAIL_DRIVER smtp
ENV MAIL_HOST mailtrap.io
ENV MAIL_PORT 2525
ENV MAIL_USERNAME null
ENV MAIL_PASSWORD null

WORKDIR /var/www/laravel
EXPOSE 80
