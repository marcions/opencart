FROM php:8.2-apache

# Install PHP extensions
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd zip mysqli pdo_mysql intl opcache \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

# PHP config
RUN echo "file_uploads = On\nmemory_limit = 256M\nupload_max_filesize = 128M\npost_max_size = 128M\nmax_execution_time = 300" \
    > /usr/local/etc/php/conf.d/opencart.ini

# Apache VirtualHost
RUN printf '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html\n\
    <Directory /var/www/html>\n\
        Options -Indexes +FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>\n' > /etc/apache2/sites-available/000-default.conf

# Copy entrypoint and OpenCart source
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
COPY upload/ /var/www/html/

# Storage dir outside webroot
RUN mkdir -p /storage/cache /storage/download /storage/logs /storage/session /storage/upload \
    && chown -R www-data:www-data /storage /var/www/html \
    && chmod -R 755 /var/www/html

EXPOSE 80
ENTRYPOINT ["/docker-entrypoint.sh"]
