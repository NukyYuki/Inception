#!/bin/bash

sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000' /etc/php/8.2/fpm/pool.d/wpress.conf

echo "WordPress waiting for MariaDB to be ready..."
until mariadb -h mariadb \
    --port="$MYSQL_PORT" \
    -u"$MYSQL_USER" \
    -p"$MYSQL_PASSWORD" \
    -e "SELECT 1" &> /dev/null; do
    echo "Waiting for MariaDB..."
    sleep 1
done

echo "MariaDB is ready. Initializing WordPress database..."