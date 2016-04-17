FROM ubuntu:14.04

MAINTAINER "Eduardo Bizarro" <edbizarro@gmail.com"

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

WORKDIR /tmp

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# Update and install some useful apts
RUN apt-get update

# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d
RUN apt-get upgrade -y

# Install Nginx
RUN apt-get update -y && \
    apt-get install -y nginx \
      software-properties-common \
      python-software-properties \
      openssl \
      mcrypt \
      curl \
      unzip \

    && apt-get --purge autoremove

RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update

# PHP Extensions
RUN apt-get install -y --force-yes php7.0-fpm php7.0-mcrypt php7.0-zip php7.0-xml php7.0-mbstring php7.0-curl php7.0-json php7.0-mysql php7.0-tokenizer php7.0-cli

RUN /etc/init.d/php7.0-fpm start

VOLUME /root/composer

# Environmental Variables
ENV COMPOSER_HOME /root/composer

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#RUN /usr/local/bin/composer global require hirak/prestissimo

# Goto temporary directory.
WORKDIR /tmp


# Apply Nginx configuration
ADD config/nginx.conf /opt/etc/nginx.conf
ADD config/laravel /etc/nginx/sites-available/laravel
RUN ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/laravel && \
    rm /etc/nginx/sites-enabled/default

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /data/www
RUN mkdir -p /data/logs

VOLUME ["/data"]

# PORTS
EXPOSE 80
EXPOSE 443
