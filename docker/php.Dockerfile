FROM php:8.3-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libxslt1-dev \
    libonig-dev \
    unzip \
    zip \
    git \
    libssh-dev \
    libssl-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    libxpm-dev \
    libvpx-dev \
    libcurl4-openssl-dev \
    libgettextpo-dev \
    && docker-php-ext-install \
        bcmath \
        calendar \
        ctype \
        curl \
        dom \
        exif \
        fileinfo \
        ftp \
        gettext \
        hash \
        iconv \
        intl \
        mbstring \
        mysqli \
        pdo_mysql \
        pcntl \
        shmop \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        tokenizer \
        xml \
        xmlreader \
        xmlwriter \
        xsl \
        zip \
    && pecl install redis igbinary \
    && docker-php-ext-enable redis igbinary \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Set working directory
WORKDIR /var/www/html

# Copy app code
COPY app/ /var/www/html/

# Permissions
RUN chown -R www-data:www-data /var/www/html
