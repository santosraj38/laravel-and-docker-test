#this is a docker file
FROM php:7.2-fpm-alpine

# install dependencies
RUN apk add --update git shadow $PHPIZE_DEPS \
  && apk add --update --no-cache --virtual .dev-deps \
    openssl-dev \
    # dep of intl ext
    icu-dev \
    # dep of mcrypt ext
    libmcrypt-dev \
    # dep of zip ext
    zlib-dev \
  # install intl
  && docker-php-ext-configure intl \
  # install redis
  # && pecl install redis \
  # && docker-php-ext-enable redis \
  # install other required extensions
  && docker-php-ext-install -j$(nproc) \
    bcmath \
    intl \
    mysqli \
    opcache \
    pdo_mysql \
    pcntl \
    zip \
  # cleanup
  && { find /usr/local/lib -type f -print0 | xargs -0r strip --strip-all -p 2>/dev/null || true; } \
  && rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/* \
  # update dir permissions
  && mkdir -p /app /var/www/html && chown -R www-data:www-data /app /var/www/html

# install composer binary
COPY --from=composer:1.10 /usr/bin/composer /usr/bin/composer

# set user and workdir
USER www-data
WORKDIR /var/www/html

# install composer parallel plugin
RUN composer global require hirak/prestissimo \
  --prefer-dist --no-interaction --no-plugins --no-scripts

RUN composer install --prefer-dist --no-interaction
