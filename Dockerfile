FROM php:8.2-fpm

# 1️⃣ Base dependencies
RUN apt-get update && apt-get install -y \
    unzip zip git curl wget vim jq groff less \
    build-essential autoconf pkg-config \
    python3 python3-pip ca-certificates \
    nginx redis-server supervisor \
    && echo "✅ Core tools installed"

# 2️⃣ PHP extensions & PECL
RUN apt-get install -y \
    libxml2-dev libxslt1-dev libonig-dev libzip-dev libicu-dev libssl-dev \
    libjpeg62-turbo-dev libpng-dev libfreetype6-dev libwebp-dev libxpm-dev libvpx-dev \
    libcurl4-openssl-dev zlib1g-dev libgettextpo-dev gettext \
    libgmp-dev libreadline-dev libtidy-dev libdb-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        bcmath calendar ctype curl dom exif ftp gd \
        gettext iconv intl mbstring mysqli opcache \
        pdo pdo_mysql pcntl shmop sockets sysvmsg sysvsem sysvshm \
        tidy xml xmlwriter xsl zip \
    && pecl install redis igbinary \
    && docker-php-ext-enable redis igbinary \
    && echo "✅ PHP & PECL extensions installed"

# 3️⃣ Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    echo "✅ Composer installed"

# 4️⃣ Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/aws /tmp/awscliv2.zip && \
    echo "✅ AWS CLI v2 installed"

# 5️⃣ Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 6️⃣ SSM: Fetch .env
ARG AWS_PARAMETER_NAME
ARG AWS_REGION
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

ENV AWS_REGION=${AWS_REGION} \
    AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

RUN mkdir -p /var/www/html && \
    aws ssm get-parameter \
        --with-decryption \
        --name "${AWS_PARAMETER_NAME}" \
        --output text \
        --region "${AWS_REGION}" \
        --query 'Parameter.Value' > /var/www/html/.env

# 7️⃣ Copy configuration files
COPY ./docker-files/nginx.conf /etc/nginx/nginx.conf
COPY ./docker-files/server.conf /etc/nginx/conf.d/default.conf
COPY ./docker-files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 8️⃣ Application setup
WORKDIR /var/www/html

# Copy Composer project metadata & install dependencies
COPY composer.json composer.lock ./
RUN composer install --no-interaction --prefer-dist --no-dev

# Copy app source
COPY ./app ./app
RUN chown -R www-data:www-data /var/www/html

# 9️⃣ Runtime folders & permissions
RUN mkdir -p /var/run/php /tmp/nginx_cache \
    && chmod -R 777 /tmp/nginx_cache \
    && chown -R www-data:www-data /var/run/php \
    && chmod 755 /var/run/php

# 🔟 Expose ports & run
EXPOSE 80 443 6379
CMD ["/usr/bin/supervisord"]
