#!/bin/bash
# =========================
# MARIADB INITIALIZATION SCRIPT
# =========================
# This script:
# 1. Initializes the MySQL data directory if needed
# 2. Starts MariaDB server temporarily
# 3. Creates database and users
# 4. Sets root password
# 5. Restarts MariaDB server

set -e

# =========================
# INITIALIZE DATABASE
# =========================
echo "[DEBUG] Checking if database is initialized..."
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "[DEBUG] Initializing MariaDB data directory..."
	mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db
	echo "[DEBUG] Database directory initialized"
fi

# =========================
# START MARIADB TEMPORARILY
# =========================
echo "[DEBUG] Starting MariaDB server (background mode)..."
mysqld_safe &
MARIADB_PID=$!

# Wait for MariaDB to be ready
echo "[DEBUG] Waiting for MariaDB to become ready..."
for i in {30..0}; do
	if mysqladmin ping --silent; then
		echo "[DEBUG] MariaDB server is up and running!"
		break
	fi
	if [ $i -eq 0 ]; then
		echo "[ERROR] MariaDB server failed to start."
		exit 1
	fi
	echo "[DEBUG] Waiting for MariaDB... ($i seconds left)"
	sleep 1
done

# =========================
# CREATE DATABASE AND USERS
# =========================
if ! [ -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
	echo "[DEBUG] Creating database and users..."

	mysql -u root << EOF
	-- Set password for root user
	ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

	-- Create database for WordPress
	CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

	-- Create WordPress user
	CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

	-- Grant all privileges on WordPress database to user
	GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

	-- Apply changes
	FLUSH PRIVILEGES;
EOF
	echo "[DEBUG] Database and user created successfully!"
else
	echo "[DEBUG] Database already exists. Skipping initialization."
	
	# Still set root password
	mysql -u root << EOF
	ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
	FLUSH PRIVILEGES;
EOF
fi

# =========================
# RESTART MARIADB
# =========================
echo "[DEBUG] Shutting down temporary MariaDB instance..."
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown 2> /dev/null || true

wait $MARIADB_PID 2> /dev/null || true

echo "[DEBUG] Starting MariaDB server (foreground mode)..."
exec "$@"