FROM php:7.1.7-fpm-alpine

COPY entrypoint.sh /usr/bin/container_entrypoint

ENV \
 DOCUMENT_ROOT=/var/www/html \
 WORDPRESS_TARBALL=/home/wordpress/wordpress.tar.gz \
 WORDPRESS_LATEST_SOURCE=https://wordpress.org/latest.tar.gz \
 WORDPRESS_SECRET_GENERATION_API=https://api.wordpress.org/secret-key/1.1/salt/

RUN export nproc="$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1)" \
 && chmod a+x /usr/bin/container_entrypoint \
 && apk upgrade --update && apk add --update --no-cache --virtual .php-extensions \
            autoconf \
            curl-dev \
            dpkg \
            dpkg-dev \
            file \
            g++ \
            gcc \
            libc-dev \
            libjpeg-turbo-dev \
            libmcrypt-dev \
            libpng-dev \
            libwebp-dev \
            libxml2-dev \
            libpng-dev \
            libxpm-dev \
            make \
            pcre-dev \
            re2c \
 && docker-php-ext-install -j${nproc} \
            curl \
            gd \
            mbstring \
            mcrypt \
            mysqli \
            xml \
            xmlrpc \
 && apk del .php-extensions \
 && apk upgrade --update && apk add --update --no-cache \
            libmcrypt \
            libpng \
 # add wordpress user and a directory to hold wp source
 && adduser -S wordpress \
 && curl -Lo ${WORDPRESS_TARBALL} ${WORDPRESS_LATEST_SOURCE}

USER wordpress

ENTRYPOINT container_entrypoint
