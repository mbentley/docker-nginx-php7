FROM mbentley/nginx:latest
MAINTAINER Matt Bentley <mbentley@mbentley.net>

RUN echo '@edge http://nl.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories &&\
  apk add --no-cache bind-tools imagemagick@edge php7-curl php7-gd php7-fpm php7-imagick php7-mcrypt php7-memcached php7-mysqli ssmtp supervisor wget whois &&\
  mkdir /etc/supervisor.d &&\
  sed -i 's/post_max_size = 8M/post_max_size = 16M/g' /etc/php7/php.ini &&\
  sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 16M/g' /etc/php7/php.ini &&\
  sed -i "s#listen = 127.0.0.1:9000#listen = /var/run/php/php-fpm7.sock#g" /etc/php7/php-fpm.d/www.conf &&\
  sed -i "s#^user = nobody#user = www-data#g" /etc/php7/php-fpm.d/www.conf &&\
  sed -i "s#^group = nobody#group = www-data#g" /etc/php7/php-fpm.d/www.conf &&\

ENV FASTCGI_PASS="unix:/var/run/php/php-fpm7.sock"
COPY default /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor.d/supervisor.ini

RUN mkdir /var/run/php &&\
  chown -R www-data:www-data /var/log/php7 /var/run/php

EXPOSE 80
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
