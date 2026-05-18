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

echo "MariaDB is ready. Initializing WordPress setup..."

# create config if it doesn't exist
if [ ! -f "/var/www/html/wp-config.php"]; then
    echo "Default wp-config.php not found, Creating one"

    echo "cleaning up"
    rm -rf *

    echo "Downloading latest WordPress"
    wp core download --allow-root
    echo "Wordpress downloaded"

    echo "Creating wp-config.php"
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="mariadb:$MYSQL_PORT" \
        --allow-root
    echo "wp-config.php created"

    echo "Installing WordPress"
    wp core install \
        --url="https://$DOMAIN_NAME" \
        --title="${SITE_TITLE:-Inception}" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root
    echo "WordPress installed"

    echo "Creating second user"
    wp user create \
        "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author \
        --allow-root
    echo "Second user created"
fi

echo "Setting up permissions"

chmod -R 755 /var/www/html

mkdir -p /var/www/html/wp-content/uploads
chmod -R 755 /var/www/html/wp-content
chmod -R 755 /var/www/html/wp-content/uploads

echo "Starting PHP-FPM"
exec /usr/sbin/php8.2-fpm -F