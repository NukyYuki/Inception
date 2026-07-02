FROM debian:bookworm

# =========================
# DEPENDENCIES
# =========================
# Install PHP-FPM and required modules for WordPress
RUN apt-get update && apt-get install -y \
	php8.2-fpm \
	php8.2-mysql \
	curl \
	mariadb-client \
	dos2unix

# =========================
# WORDPRESS CLI (WP-CLI)
# =========================
# Download and install WP-CLI for WordPress automation
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

# =========================
# PHP-FPM CONFIGURATION
# =========================
# Copy custom PHP-FPM pool configuration
# Maps to listening port configured in wpress.conf
COPY conf/wpress.conf /etc/php/8.2/fpm/pool.d/wpress.conf

# =========================
# REQUIRED DIRECTORIES
# =========================
# Create PHP-FPM runtime directory
RUN mkdir -p /run/php

# =========================
# WORKDIR
# =========================
# WordPress installation and files will be stored here
WORKDIR /var/www/html

# =========================
# INITIALIZATION SCRIPT
# =========================
# Copy and set executable permissions on the WordPress initialization script
COPY tools/wpress-init.sh /usr/local/bin/wpress-init.sh
RUN dos2unix /usr/local/bin/wpress-init.sh && chmod +x /usr/local/bin/wpress-init.sh

# =========================
# USER
# =========================
# Run initialization as root, then drop privileges in the startup script
USER root

# =========================
# STARTUP
# =========================
# Run initialization script first using bash -c to bypass shared folder permission issues
ENTRYPOINT ["bash", "-c", "/usr/local/bin/wpress-init.sh && exec \"$@\"", "--"]

# Run PHP-FPM in foreground (-F) to keep container alive
CMD ["/usr/sbin/php-fpm8.2", "-F"]