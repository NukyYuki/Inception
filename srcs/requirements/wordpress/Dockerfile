FROM debian:bookworm

# =========================
# DEPENDENCIES
# =========================
RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    curl \
    mariadb-client

# =========================
# WP-CLI
# =========================
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# =========================
# PHP-FPM CONFIG
# =========================
COPY conf/wpress.conf /etc/php/8.2/fpm/pool.d/www.conf

# =========================
# REQUIRED DIRS
# =========================
RUN mkdir -p /run/php

# =========================
# WORKDIR
# =========================
WORKDIR /var/www/html

# =========================
# SCRIPT (your original one)
# =========================
COPY tools/wpress-init.sh /usr/local/bin/wordpress-init.sh
RUN chmod +x /usr/local/bin/wordpress-init.sh

# =========================
# STARTUP
# =========================
ENTRYPOINT ["/usr/local/bin/wordpress-init.sh"]

CMD ["/usr/sbin/php-fpm8.2", "-F"]