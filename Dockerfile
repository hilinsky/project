#Use the official PHP image with FPM
FROM php:8.0-fpm

#Maintainer
LABEL maintainer="victorhilinsky@gmail.com"

# Install Nginx and necessary PHP extensions
RUN apt-get update && apt-get install -y \
    nginx \
    net-tools \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && docker-php-ext-install mysqli \
    && docker-php-ext-enable mysqli

# Set the working directory
WORKDIR /var/www/html

# Download and extract WordPress
RUN curl -O https://wordpress.org/latest.tar.gz \
    && tar -xzf latest.tar.gz --strip-components=1 \
    && rm latest.tar.gz

# Copy Nginx configuration file
COPY ./src/nginx.conf /etc/nginx/nginx.conf

# Copy the custom theme into the WordPress themes directory
COPY ./src/hilinsky-theme /var/www/html/wp-content/themes/hilinsky-theme

# Set permissions
RUN chown -R www-data:www-data /var/www/html
RUN mkdir -p /var/lib/nginx/logs && \
    chown -R www-data:www-data /var/lib/nginx/logs && \
    chmod 755 /var/lib/nginx/logs
RUN mkdir -p /var/lib/nginx/body && \
    chown -R www-data:www-data /var/lib/nginx/ && \
    chmod -R 755 /var/lib/nginx/

#Change nginx pid location
RUN mkdir -p /var/run && \
    chown -R www-data:www-data /var/run/

# Expose the port that NGINX will listen on
EXPOSE 8080

# Start NGINX and PHP-FPM
CMD ["sh", "-c", "nginx && php-fpm"]

#Change user
USER www-data
