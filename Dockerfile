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
        supervisor                          \
	    wget

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

# Configure buyerfirst-web
ENV APP_ENV local
ENV APP_DEBUG true
ENV APP_STORAGE /var/run/application
ENV DB_DATABASE application
ENV DB_HOST localhost
ENV DB_PASSWORD application
ENV DB_USERNAME application
ENV DEVELOPER_EMAIL team@reflexions.co

COPY . /var/www/application
WORKDIR /var/www/application

    # apache
RUN cp vendor/reflexions/content-infrastructure/001-application.conf /etc/apache2/sites-available/ && \
    ln -s /etc/apache2/sites-available/001-application.conf /etc/apache2/sites-enabled/ && \
    unlink /etc/apache2/sites-enabled/000-default.conf && \

    # apache run dirs
    mkdir /var/run/application && \
    mkdir /var/run/application/app && \
    mkdir /var/run/application/framework && \
    mkdir /var/run/application/framework/sessions && \
    mkdir /var/run/application/framework/views && \
    mkdir /var/run/application/framework/cache && \
    mkdir /var/run/application/logs && \
    
    # crontab
    cp vendor/reflexions/content-infrastructure/crontab /var/spool/cron/crontabs/www-data && \
    chown www-data.crontab /var/spool/cron/crontabs/www-data && \
    chmod 0600 /var/spool/cron/crontabs/www-data && \

    # supervisor
    cp vendor/reflexions/content-infrastructure/supervisord.conf /etc/supervisor/ && \
    cp vendor/reflexions/content-infrastructure/supervisor.conf.d/* /etc/supervisor/conf.d/ && \
    mkdir /var/run/application/logs/supervisor/ && \

    # permissions and start script
    chown -R www-data /var/run/application && \
    chmod -R 775 /var/run/application && \
    cp vendor/reflexions/content-infrastructure/start.sh /start.sh && \
    chmod 755 /start.sh

# Elastic Beanstalk deploy skips .gitignore'd directories
# Frontend build should be run and committed to public/build
RUN composer install

EXPOSE 80
ENTRYPOINT ["/start.sh"]