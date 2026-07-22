dockerfile
# PHP 8.2 with Apache
FROM php:8.2-apache

# System dependencies install
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libxml2-dev \
    libzip-dev \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# PHP extensions install
RUN docker-php-ext-install \
    pdo_mysql \
    mysqli \
    mbstring \
    gd \
    zip \
    xml \
    pcntl

# Apache mod_rewrite enable
RUN a2enmod rewrite

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . /var/www/html/

# Copy Apache config if exists
COPY .apache-config.conf /etc/apache2/sites-available/000-default.conf 2>/dev/null || true

# Install PHP dependencies if composer.json exists
RUN if [ -f "composer.json" ]; then composer install --no-interaction --optimize-autoloader --no-dev; fi

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage 2>/dev/null || true \
    && chmod -R 755 /var/www/html/bootstrap/cache 2>/dev/null || true \
    && chmod 666 /var/www/html/users.json 2>/dev/null || true \
    && chmod 666 /var/www/html/error.log 2>/dev/null || true

# Expose port 80
EXPOSE 80
