FROM php:8.2-fpm

# Step 1: Install system build tools and core libraries
RUN apt-get update && apt-get install -y \
    autoconf \
    build-essential \
    pkg-config \
    unzip \
    zip \
    git \
    curl \
    wget \
    && echo "✅ Build tools installed"

# Step 2: Install all dependencies required for PHP extensions
RUN apt-get install -y \
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
    && echo "✅ All PHP extension dependencies installed"

# Step 3: Configure GD library with proper flags
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && echo "✅ GD configured"

# Step 4: Install PHP core extensions (grouped for clarity)
RUN docker-php-ext-install \
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
    && echo "✅ PHP extensions installed"

# Step 5: Install and enable PECL extensions
RUN pecl install redis igbinary \
    && docker-php-ext-enable redis igbinary \
    && echo "✅ PECL extensions installed"

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* \
    && echo "✅ Cleaned up"

# Set working directory
WORKDIR /var/www/html

# Copy app code (optional, if using with Compose)
COPY app/ /var/www/html/

# Set permissions
RUN chown -R www-data:www-data /var/www/html
