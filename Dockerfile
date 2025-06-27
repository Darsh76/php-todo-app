FROM php:8.2-fpm

LABEL maintainer="your-team@example.com"

# 1️⃣ Install base packages and dependencies
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

# 2️⃣ Configure PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install \
    dom \
    xml \
    xmlwriter \
    xsl \
    bcmath \
    calendar \
    ctype \
    curl \
    exif \
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
    zip && \
    echo "✅ PHP extensions installed"

# 3️⃣ Install PECL extensions
RUN pecl install redis igbinary && \
    docker-php-ext-enable redis igbinary && \
    echo "✅ PECL extensions installed"

# 4️⃣ Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 5️⃣ Copy Nginx and Supervisor config
COPY ./docker-files/nginx.conf /etc/nginx/nginx.conf
COPY ./docker-files/server.conf /etc/nginx/conf.d/default.conf
COPY ./docker-files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 6️⃣ Copy SSL certificates (Certbot-generated)
COPY ./docker-files/certs/fullchain.pem /etc/ssl/certs/fullchain.pem
COPY ./docker-files/certs/privkey.pem /etc/ssl/private/privkey.pem

# 7️⃣ Create necessary directories
RUN mkdir -p /var/run/php /tmp/nginx_cache && \
    chmod -R 777 /tmp/nginx_cache && \
    chown -R www-data:www-data /var/run/php && \
    chmod 755 /var/run/php

# 8️⃣ App code
WORKDIR /var/www/html
COPY ./app /var/www/html
RUN chown -R www-data:www-data /var/www/html

# 🔌 Expose HTTP, HTTPS, Redis ports
EXPOSE 80 443 6379

# 🔁 Start all services via Supervisor
CMD ["/usr/bin/supervisord"]
