#!/bin/bash
set -e


sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|g' /etc/php/8.2/fpm/pool.d/www.conf

# Wait for the database to be ready
echo "[DEBUG] Waiting for MariaDB..."
until mariadb -h mariadb \
    --port="$MYSQL_PORT" \
    -u"$MYSQL_USER" \
    -p"$MYSQL_PASSWORD" \
    "$MYSQL_DATABASE" \
    -e "SELECT 1;" >/dev/null 2>&1; do
    echo "[DEBUG] MariaDB not ready yet..."
    sleep 2
done


# Create config if wp-config.php doesn't exist
if [ ! -f "wp-config.php" ]; then
    echo "[DEBUG] wp-config.php not found, starting setup"

    echo "[DEBUG] Cleaning directory"
    rm -rf *

    echo "[DEBUG] Downloading WordPress"
    wp core download --allow-root
    echo "[DEBUG] WordPress downloaded"

    echo "[DEBUG] Creating config"
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="mariadb:$MYSQL_PORT" \
        --allow-root
    echo "[DEBUG] wp-config created"

    echo "[DEBUG] Installing WordPress"
    wp core install \
        --url="https://$DOMAIN_NAME" \
        --title="${SITE_TITLE:-Inception}" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root
    echo "[DEBUG] WordPress installed"

    echo "[DEBUG] Creating second user"
    wp user create \
        "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author \
        --allow-root
    echo "[DEBUG] Second user created"
fi

echo "[DEBUG] Fixing permissions"
#chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "[DEBUG] Preparing uploads folder"
mkdir -p /var/www/html/wp-content/uploads
chmod 755 /var/www/html/wp-content
chmod 755 /var/www/html/wp-content/uploads

# Start PHP-FPM
echo "[DEBUG] Starting PHP-FPM"
exec /usr/sbin/php-fpm8.2 -F