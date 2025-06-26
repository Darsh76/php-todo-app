FROM php:8.2-fpm

# Install system dependencies required by PHP extensions
RUN apt-get update && apt-get install -y \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libxslt1-dev \
    libonig-dev \
    unzip \
    zip \
    git \
    libssl-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libwebp-dev \
    libxpm-dev \
    libvpx-dev \
    libcurl4-openssl-dev \
    libgettextpo-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libfreetype6-dev \
    zlib1g-dev \
    libgmp-dev \
    libreadline-dev \
    libtidy-dev \
    libdb-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
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

# Copy app code into container
COPY app/ /var/www/html/

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html
