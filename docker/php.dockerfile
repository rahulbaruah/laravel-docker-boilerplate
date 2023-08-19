FROM php:8.2.3-fpm-alpine3.16

LABEL maintainer="Rahul Baruah <baruah.rahul.88@gmail.com>"

# set composer related environment variables
ENV PATH="/composer/vendor/bin:$PATH" \
    COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/composer

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer --ansi --version --no-interaction

# install necessary alpine packages
RUN apk update && apk add --no-cache \
    $PHPIZE_DEPS \
    linux-headers \
    zip \
    unzip \
    dos2unix \
    supervisor \
    libpng-dev \
    libzip-dev \
    libxml2-dev \
    libwebp-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    curl \
    jpegoptim optipng pngquant gifsicle \
    git \
    php8-pecl-redis

# compile native PHP packages
# https://github.com/mlocati/docker-php-extension-installer
RUN docker-php-ext-install \
    exif \
    pcntl \
    bcmath \
    mysqli \
    pdo_mysql \
    opcache

# Install GD extension
RUN docker-php-ext-configure gd \
            --with-jpeg \
            --with-webp \
            --with-freetype \
    && docker-php-ext-install gd

# Install additional packages from PECL
RUN pecl install zip && docker-php-ext-enable zip \
    && pecl install igbinary && docker-php-ext-enable igbinary \
    && yes | pecl install redis && docker-php-ext-enable redis

# For Xdebug
# && pecl install xdebug-3.1.6 && docker-php-ext-enable xdebug

# RUN pecl channel-update https://pecl.php.net/channel.xml
RUN pecl install swoole && docker-php-ext-enable swoole

# environment arguments
ARG UID
ARG GID
ARG DOCKER_USER
ARG DOCKER_GROUP

ENV UID=${UID}
ENV GID=${GID}
ENV DOCKER_USER=${DOCKER_USER}
ENV DOCKER_GROUP=${DOCKER_GROUP}

# Dialout group in alpine linux conflicts with MacOS staff group's gid, whis is 20. So we remove it.
RUN delgroup dialout

# Creating user and group
RUN addgroup -g ${GID} --system ${DOCKER_GROUP}
RUN adduser -G ${DOCKER_GROUP} --system -D -s /bin/sh -u ${UID} ${DOCKER_USER}

COPY ./docker/php/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./docker/php/conf.d /usr/local/etc/php/conf.d

# Modify php fpm configuration to use the new user's priviledges using modify_config.sh.
RUN mkdir -p /tmp/scripts/
COPY ./docker/php/modify_config.sh /tmp/scripts/
RUN chmod +x /tmp/scripts/modify_config.sh

RUN /tmp/scripts/modify_config.sh /usr/local/etc/php-fpm.d/www.conf \
    "__APP_USER" \
    "${DOCKER_USER}" \
 && /tmp/scripts/modify_config.sh /usr/local/etc/php-fpm.d/www.conf \
    "__APP_GROUP" \
    "${DOCKER_GROUP}" \
;
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf



# Only use this when no mount
# RUN mkdir -p /var/www/html
# WORKDIR /var/www/html

# COPY ./src/site1/composer.json ./src/site1/composer.lock* ./
# RUN composer install --no-scripts --no-autoloader --ansi --no-interaction
# COPY ./src/ /var/www/html
# RUN chmod -R 777 /var/www/html/storage
# RUN chmod -R 777 /var/www/html/bootstrap/cache

# RUN chown -R ${DOCKER_USER}:${DOCKER_GROUP} /var/www/html
