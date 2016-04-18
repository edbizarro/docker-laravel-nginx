FROM nginx:1.9.14

MAINTAINER "Eduardo Bizarro" <edbizarro@gmail.com"

RUN mkdir -p /etc/nginx/sites-available/
RUN mkdir -p /etc/nginx/sites-enabled/

# Apply Nginx configuration
COPY config/nginx.conf /etc/nginx/nginx.conf
#COPY config/laravel /etc/nginx/sites-available/laravel
#RUN ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/laravel

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /data/www
RUN mkdir -p /data/logs

VOLUME ["/data"]

# PORTS
EXPOSE 80 443
