#!/bin/bash
# =========================
# WORDPRESS INITIALIZATION SCRIPT
# =========================
# This script:
# 1. Configures PHP-FPM to listen on port 9000
# 2. Waits for MariaDB to be ready
# 3. Downloads and configures WordPress
# 4. Sets up proper file permissions
# 5. Starts PHP-FPM

set -e

# =========================
# CONFIGURE PHP-FPM
# =========================
# The pool config already listens on TCP port 9000.

# =========================
# WAIT FOR MARIADB
# =========================
echo "[DEBUG] Waiting for MariaDB to be ready..."
until mariadb -h mariadb \
	--port="$MYSQL_PORT" \
	-u"$MYSQL_USER" \
	-p"$MYSQL_PASSWORD" \
	-e "SELECT 1" &> /dev/null; do
	echo "[DEBUG] MariaDB not ready yet, waiting..."
	sleep 2
done
echo "[DEBUG] MariaDB is ready!"

# =========================
# INITIALIZE WORDPRESS
# =========================
echo "[DEBUG] Initializing WordPress..."

if [ ! -f "/var/www/html/wp-config.php" ]; then
	echo "[DEBUG] wp-config.php not found, starting setup..."

	echo "[DEBUG] Cleaning directory..."
	rm -rf *

	echo "[DEBUG] Downloading WordPress..."
	wp core download --allow-root
	echo "[DEBUG] WordPress downloaded successfully"

	echo "[DEBUG] Creating wp-config.php..."
	wp config create \
		--dbname="$MYSQL_DATABASE" \
		--dbuser="$MYSQL_USER" \
		--dbpass="$MYSQL_PASSWORD" \
		--dbhost="mariadb:$MYSQL_PORT" \
		--allow-root
	echo "[DEBUG] wp-config.php created"

	echo "[DEBUG] Installing WordPress..."
	wp core install \
		--url="https://$DOMAIN_NAME" \
		--title="${SITE_TITLE:-Inception}" \
		--admin_user="$WP_ADMIN_USER" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL" \
		--allow-root
	echo "[DEBUG] WordPress installed successfully"

	echo "[DEBUG] Creating additional user..."
	wp user create \
		"$WP_USER" "$WP_USER_EMAIL" \
		--user_pass="$WP_USER_PASSWORD" \
		--role=author \
		--allow-root
	echo "[DEBUG] Additional user created"
fi

# =========================
# SET UP PERMISSIONS
# =========================
echo "[DEBUG] Setting up file permissions..."
# Set directories to 755 (readable/executable for www-data)
find /var/www/html -type d -exec chmod 755 {} \;
# Set files to 644 (readable for www-data)
find /var/www/html -type f -exec chmod 644 {} \;

# Prepare uploads directory with write permissions for www-data
mkdir -p /var/www/html/wp-content/uploads
chmod -R 775 /var/www/html/wp-content/uploads
chown -R www-data:www-data /var/www/html/wp-content/uploads

# Set proper ownership for all WordPress files
chown -R www-data:www-data /var/www/html

echo "[DEBUG] File permissions set successfully"

# =========================
# START PHP-FPM
# =========================
echo "[DEBUG] Starting PHP-FPM..."
exec "$@"