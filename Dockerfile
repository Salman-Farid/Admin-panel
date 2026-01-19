# Use PHP 8.3 FPM as base image
FROM php:8.3-fpm

# Set working directory
WORKDIR /var/www/html

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    libpq-dev \
    nodejs \
    npm \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install \
    pdo_mysql \
    pdo_pgsql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy application files
COPY . /var/www/html

# Install PHP dependencies without running scripts first to avoid early failures
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist --no-scripts

# Create necessary Laravel directories if they don't exist
RUN mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views \
    && mkdir -p bootstrap/cache

# Then manually run package discovery
RUN php artisan package:discover --ansi || echo "Package discovery failed, continuing..."

# Install Node dependencies and build frontend assets
# NOTE: Setting NODE_OPTIONS=--openssl-legacy-provider enables the legacy OpenSSL provider
# This is required for webpack 4.x (used by laravel-mix 5.x) to work with Node.js 17+
# which uses OpenSSL 3.0 that removed support for the MD4 hash algorithm
# TODO: Consider upgrading to laravel-mix 6+ (webpack 5) to remove this workaround
ENV NODE_OPTIONS=--openssl-legacy-provider
RUN npm ci && npm run production

# Set proper file permissions for Laravel storage and bootstrap/cache directories
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 8000
EXPOSE 8000

# Start the application
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
