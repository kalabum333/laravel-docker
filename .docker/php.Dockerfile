FROM php:8.3-fpm
 
# UID/GID trùng với người dùng trên máy chủ để không lỗi quyền ghi file
ARG WWW_UID=1000
ARG WWW_GID=1000
 
# Thư viện hệ thống và tiện ích
RUN apt-get update && apt-get install -y --no-install-recommends \
        git curl zip unzip \
        libzip-dev libpng-dev libjpeg-dev libfreetype6-dev \
        libonig-dev libxml2-dev libicu-dev \
    && rm -rf /var/lib/apt/lists/*
 
# Các extension PHP mà Laravel cần
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql mbstring exif pcntl bcmath gd zip intl opcache
 
# Cài Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_HOME=/tmp/composer
 
# Đồng bộ UID/GID của www-data với máy chủ
RUN groupmod -o -g $WWW_GID www-data && usermod -o -u $WWW_UID -g $WWW_GID www-data
 
WORKDIR /var/www/html
 
USER www-data
 
EXPOSE 9000
CMD ["php-fpm"]
