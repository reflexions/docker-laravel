FROM debian:jessie

MAINTAINER "Patrick Way" <patrick@reflexions.co>

WORKDIR /tmp
ENV LANGUAGE en_US.UTF-8

# ffmpeg not in debian:jessie
RUN echo deb http://www.deb-multimedia.org jessie main non-free >> /etc/apt/sources.list && \
    apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install deb-multimedia-keyring --force-yes --assume-yes

# Install packages
# Split into steps to minimize impact of mirror errors
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
		apache2 							\
        beanstalkd                          \
		cron                                \
        curl 								\
        locales 							\
	    git-core                            \
	    wget

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
		python \
		python-pip
RUN pip install supervisor==3.2.0

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
		ffmpeg

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
	    imagemagick

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
	    php5-sqlite

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

# Configuration
ENV LARAVEL_WWW_PATH /var/www/laravel
ENV LARAVEL_RUN_PATH /var/run/laravel
ENV LARAVEL_STORAGE_PATH /var/run/laravel/storage
ENV LARAVEL_BOOTSTRAP_CACHE_PATH /var/run/laravel/bootstrap/cache
ENV GITHUB_TOKEN Your_Github_Token

ENV APP_ENV local
ENV APP_DEBUG true
ENV APP_KEY SomeRandomString

ENV DB_CONNECTION postgres
ENV DB_HOST postgres
ENV DB_DATABASE application
ENV DB_USERNAME laravel
ENV DB_PASSWORD password

# Match DB_USERNAME, DB_PASSWORD, and DB_DATABASE above
ENV POSTGRES_DB application
ENV POSTGRES_USER laravel
ENV POSTGRES_PASSWORD password

ENV CACHE_DRIVER file
ENV SESSION_DRIVER file
ENV QUEUE_DRIVER sync

ENV MAIL_DRIVER smtp
ENV MAIL_HOST mailtrap.io
ENV MAIL_PORT 2525
ENV MAIL_USERNAME null
ENV MAIL_PASSWORD null

# start and setup scripts
# setup script runs on container startup to utilize GITHUB_TOKEN env variable
COPY . /usr/share/docker-laravel
WORKDIR /usr/share/docker-laravel
RUN chmod 755 /usr/share/docker-laravel/bin/setup.sh && \
    chmod 755 /usr/share/docker-laravel/bin/start.sh
ENTRYPOINT ["/usr/share/docker-laravel/bin/start.sh"]


WORKDIR /var/www/laravel
EXPOSE 80