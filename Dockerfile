FROM phusion/baseimage:0.9.18

MAINTAINER "Eduardo Bizarro" <edbizarro@gmail.com"

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

WORKDIR /tmp

# Install Nginx
RUN apt-get update -y && \
    apt-get install -y nginx \

    && apt-get --purge autoremove

RUN DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:ondrej/php
RUN DEBIAN_FRONTEND=noninteractive apt-get update

# PHP Extensions
RUN apt-get install -y --force-yes php7.0-dev php7.0-mcrypt php7.0-zip php7.0-xml php7.0-mbstring php7.0-curl php7.0-json php7.0-mysql php7.0-tokenizer php7.0-cli

RUN /usr/sbin/php-fpm7.0

VOLUME /root/composer

# Environmental Variables
ENV COMPOSER_HOME /root/composer

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN /usr/local/bin/composer global require hirak/prestissimo

# Goto temporary directory.
WORKDIR /tmp

# Run composer and phpunit installation.
RUN composer selfupdate && \
    composer require "phpunit/phpunit:^5.3" --prefer-dist --no-interaction && \
    ln -s /tmp/vendor/bin/phpunit /usr/local/bin/phpunit && \
    rm -rf /root/.composer/cache/*

RUN composer --version

# Apply Nginx configuration
ADD config/nginx.conf /opt/etc/nginx.conf
ADD config/laravel /etc/nginx/sites-available/laravel
RUN ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/laravel && \
    rm /etc/nginx/sites-enabled/default

# Nginx startup script
RUN cp /opt/etc/nginx.conf /etc/nginx/nginx.conf
ADD config/nginx-start.sh /opt/bin/nginx-start.sh
RUN chmod u=rwx /opt/bin/nginx-start.sh

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /data/www
RUN mkdir -p /data/logs

VOLUME ["/data"]

# PORTS
EXPOSE 80
EXPOSE 443

WORKDIR /opt/bin
ENTRYPOINT ["/opt/bin/nginx-start.sh"]
