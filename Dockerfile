FROM php:8.4-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev libicu-dev libjpeg-dev libonig-dev libxml2-dev zip unzip git curl \
    libpq-dev libzip-dev libmcrypt-dev libreadline-dev libssl-dev libcurl4-openssl-dev \
    libxslt1-dev libffi-dev libmagickwand-dev libmagickcore-dev \
    && docker-php-ext-install intl pdo pdo_mysql mbstring exif pcntl bcmath gd

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set Apache to serve from Laravel's public directory
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Set working directory
WORKDIR /var/www/html

# Copy app files
COPY . .

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Composer dependencies
RUN composer install --no-dev --optimize-autoloader

# Laravel setup
RUN php artisan key:generate \
    && php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache \
    && php artisan migrate --force

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# Expose port
EXPOSE 80
