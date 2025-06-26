FROM php:8.3-fpm

# Install Redis extension
RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip \
    && docker-php-ext-install zip \
    && pecl install redis \
    && docker-php-ext-enable redis

WORKDIR /var/www/html

COPY app/ /var/www/html/

RUN chown -R www-data:www-data /var/www/html
