FROM nginx

MAINTAINER "Eduardo Bizarro" <edbizarro@gmail.com"
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
EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
