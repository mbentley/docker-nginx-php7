FROM debian:stretch
MAINTAINER Matt Bentley <mbentley@mbentley.net>

ENV NGINX_VER 1.14.2

RUN apt-get update &&\
  apt-get install -y build-essential dnsutils imagemagick libpcre3 libpcre3-dev libpcrecpp0v5 libssl-dev netbase php7.0-curl php7.0-gd php7.0-fpm php-imagick php7.0-mcrypt php-memcache php-memcached php7.0-mysql ssmtp supervisor zlib1g-dev wget whois &&\
  wget http://nginx.org/download/nginx-${NGINX_VER}.tar.gz -O /tmp/nginx-${NGINX_VER}.tar.gz &&\
  cd /tmp &&\
  tar xvf /tmp/nginx-${NGINX_VER}.tar.gz &&\
  cd /tmp/nginx-${NGINX_VER} &&\
  ./configure --sbin-path=/usr/local/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --pid-path=/var/run/nginx.pid --lock-path=/var/lock/nginx.lock --http-log-path=/var/log/nginx/access.log --with-http_dav_module --http-client-body-temp-path=/var/lib/nginx/body --with-http_ssl_module --with-http_realip_module --http-proxy-temp-path=/var/lib/nginx/proxy --with-http_stub_status_module --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --with-http_auth_request_module --user=www-data --group=www-data &&\
cd /tmp/nginx-${NGINX_VER} &&\
  make &&\
  make install &&\
  rm /etc/nginx/*.default &&\
  rm -rf /tmp/nginx-${NGINX_VER} /tmp/nginx-${NGINX_VER}.tar.gz &&\
  apt-get purge -y build-essential &&\
  apt-get autoremove -y &&\
  rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/lib/nginx /etc/nginx/sites-enabled /etc/nginx/sites-available /var/www /run/php

COPY nginx.conf /etc/nginx/nginx.conf
COPY php.conf /etc/nginx/php.conf
COPY default /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default &&\
  sed -i 's/post_max_size = 8M/post_max_size = 16M/g' /etc/php/7.0/fpm/php.ini &&\
  sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 16M/g' /etc/php/7.0/fpm/php.ini

EXPOSE 80
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]
