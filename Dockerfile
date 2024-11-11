FROM php:8.3-fpm-alpine AS base

RUN apk update --no-cache && \
    apk upgrade --no-cache
RUN apk add --no-cache \
        supervisor

FROM base AS build

RUN apk add --no-cache \
    $PHPIZE_DEPS \
    linux-headers \
    freetype-dev \
    geos-dev \
    git \
    jpeg-dev \
    icu-dev \
    libzip-dev

#####################################
# PHP Extensions
#####################################
# Install the PHP shared memory driver
RUN pecl install APCu && \
    docker-php-ext-enable apcu

# Install the PHP bcmath extension
RUN docker-php-ext-install bcmath

# Install for image manipulation
RUN docker-php-ext-install exif

# Install the FTP library
RUN docker-php-ext-install ftp

# Install the PHP graphics library
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg
RUN docker-php-ext-install gd

# Install the PHP geos extention
RUN git clone https://git.osgeo.org/gitea/geos/php-geos.git && \
    cd php-geos && \
    ./autogen.sh && \
    ./configure && \
    make && \
    mv modules/geos.so /usr/local/lib/php/extensions/no-debug-non-zts-20230831
RUN docker-php-ext-enable geos

# Install the PHP intl extention
RUN docker-php-ext-install intl

# Install the PHP mysqli extention
RUN docker-php-ext-install mysqli && \
    docker-php-ext-enable mysqli

# Install the PHP opcache extention
RUN docker-php-ext-enable opcache

# Install the PHP pcntl extention
RUN docker-php-ext-install pcntl

# Install the PHP pdo_mysql extention
RUN docker-php-ext-install pdo_mysql

# Install the PHP redis driver
RUN pecl install redis && \
    docker-php-ext-enable redis

# install XDebug but without enabling
RUN pecl install xdebug

# Install the PHP zip extention
RUN docker-php-ext-install zip

FROM base AS target

RUN apk add --no-cache \
    freetype \
    geos \
    jpeg \
    icu \
    libzip

COPY --from=build /usr/local/lib/php/extensions/no-debug-non-zts-20230831/* /usr/local/lib/php/extensions/no-debug-non-zts-20230831
COPY --from=build /usr/local/etc/php/conf.d/* /usr/local/etc/php/conf.d

#####################################
# Composer
#####################################
RUN curl -s http://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

#####################################
# PHP Additional configuration
#####################################
COPY ./php.ini $PHP_INI_DIR
