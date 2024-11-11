# PHP-FPM-ALPINE base image

A base image to build php-fpm docker images fast.

The image installs useful PHP extensions, composer and activates jit.

## Build
For local build, use for instance:

```
docker build -t base-php:8.3-fpm-alpine .
```

For docker hub build, use:

```
docker build -t ifullgaz/base-php:8.3-fpm-alpine .
```

To upload the docker hub build to docker hub, use (providing you have the appropriate permissions):

```
docker push ifullgaz/base-php:8.3-fpm-alpine
```

## Usage
1] Use the **FROM** tag at the top of the Dockerfile, such as:

```
FROM ifullgaz/base-php:8.3-fpm-alpine
```

2] Composer is found at `/usr/local/bin/composer`. Usage example:

```
RUN /usr/local/bin/composer install --no-dev
```

3] The list of available PHP extensions:

|   |   |   |   |
|---|---|---|---|
|apcu|gd|pcre|sodium|
|bcmath|hash|pcntl|SPL|
|Core|iconv|PDO|sqlite3|
|ctype|intl|pdo_sqlite|standard|
|curl|json|Phar|tokenizer|
|date|libxml|posix|xml|
|dom|mbstring|readline|xmlreader|
|exif|mysqli|redis|xmlwriter|
|fileinfo|mysqlnd|Reflection|zlib|
|filter|opcache|session|||
|ftp|openssl|SimpleXML|||
|   |   |   |   |

## php.ini file
A new `php.ini` file may be copied at `PHP_INI_DIR` in order to override the exiting file.
```
COPY ./php.ini $PHP_INI_DIR
```

## How to use pecl and docker-php-ext-*

Before using `pecl` or `docker-php-ext-*` commands, add the following statement to the Dockerfile:
```
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS
```
Then use `pecl` and `docker-php-ext-*` commands as usual, for instance:
```
# Install the PHP mysqli extention
RUN docker-php-ext-install mysqli && \
    docker-php-ext-enable mysqli
```
After all such commands, cleanup with:
```
RUN apk del --no-network .build-deps
RUN rm -rf /tmp/* /var/tmp/*
```
