FROM debian:bookworm

# Dependencies
RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    curl \
    mariadb-client

# WordPress CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# PHP-FPM configuration

COPY conf/wpress.conf /etc/php/8.2/fpm/pool.d/wpress.conf

# Required directories

RUN mkdir -p /run/php

# Work directory
WORKDIR /var/www/html

COPY tools/wpress-init.sh /usr/local/bin/wpress-init.sh
RUN chmod +x /usr/local/bin/wpress-init.sh

#Start
ENTRYPOINT [ "/usr/local/bin/wpress-init.sh" ]

CMD ["/usr/sbin/php-fpm8.2", "-F"]