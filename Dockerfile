FROM phusion/baseimage:0.9.18

MAINTAINER "Eduardo Bizarro" <edbizarro@gmail.com"

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

WORKDIR /tmp

# Install Nginx
RUN apt-get update -y && \
    apt-get install -y nginx \

    && apt-get --purge autoremove

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

RUN mkdir -p /data
VOLUME ["/data"]

# PORTS
EXPOSE 80
EXPOSE 443

WORKDIR /opt/bin
ENTRYPOINT ["/opt/bin/nginx-start.sh"]
