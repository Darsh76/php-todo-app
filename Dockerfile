FROM php:8.2-fpm

LABEL maintainer="dxrsh10@gmail.com"

# 1️⃣ Install system build tools and PHP/Nginx/Redis/Utility dependencies
RUN apt-get update && apt-get install -y \
    autoconf \
    build-essential \
    pkg-config \
    unzip \
    zip \
    git \
    curl \
    wget \
    gettext \
    libgettextpo-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libxslt1-dev \
    libonig-dev \
    libssl-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    libxpm-dev \
    libvpx-dev \
    libcurl4-openssl-dev \
    zlib1g-dev \
    libgmp-dev \
    libreadline-dev \
    libtidy-dev \
    libdb-dev \
    nginx \
    redis-server \
    supervisor \
    && echo "✅ All system and PHP dependencies installed"

# 2️⃣ Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        dom \
        xml \
        xmlwriter \
        xsl \
        bcmath \
        calendar \
        ctype \
        curl \
        exif \
        fileinfo \
        ftp \
        gettext \
        iconv \
        intl \
        mbstring \
        mysqli \
        pdo \
        pcntl \
        shmop \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        zip \
    && echo "✅ PHP core extensions installed"

# 3️⃣ Install PECL extensions
RUN pecl install redis igbinary \
    && docker-php-ext-enable redis igbinary \
    && echo "✅ PECL extensions installed"

# 4️⃣ Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* \
    && echo "✅ Cleanup complete"

# 5️⃣ Nginx configuration
COPY ./docker-files/nginx.conf /etc/nginx/nginx.conf

# 6️⃣ Supervisor configuration
COPY ./docker-files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 7️⃣ Create runtime directories
RUN mkdir -p /var/run/php /tmp/nginx_cache \
    && chmod -R 777 /tmp/nginx_cache \
    && chown -R www-data:www-data /var/run/php \
    && chmod 755 /var/run/php

# 8️⃣ Application code (optional placeholder)
WORKDIR /var/www/html
COPY ./app /var/www/html
RUN chown -R www-data:www-data /var/www/html

# 🔌 Expose Nginx and Redis ports
EXPOSE 80 6379

# 🚀 Start all services
CMD ["/usr/bin/supervisord"]
