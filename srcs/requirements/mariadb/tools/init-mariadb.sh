#!/bin/bash
# =========================
# MARIADB INITIALIZATION SCRIPT
# =========================

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
# START MARIADB WITH SKIP-GRANT-TABLES (first time only)
# =========================
echo "[DEBUG] Starting MariaDB server with --skip-grant-tables..."
mysqld --user=mysql --bind-address=0.0.0.0 --skip-grant-tables &
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
# SETUP USERS AND PERMISSIONS
# =========================
echo "[DEBUG] Setting up users and database..."
echo "[DEBUG] DB: ${MYSQL_DATABASE}, User: ${MYSQL_USER}"

mysql -u root --socket=/run/mysqld/mysqld.sock << EOF
	FLUSH PRIVILEGES;
	
	ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
	
	CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
	
	CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
	CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
	
	GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
	GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'localhost';
	
	FLUSH PRIVILEGES;
EOF

echo "[DEBUG] Setup completed!"

# =========================
# RESTART MARIADB
# =========================
echo "[DEBUG] Shutting down MariaDB instance..."
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown 2> /dev/null || true
sleep 2

wait $MARIADB_PID 2> /dev/null || true

echo "[DEBUG] Starting MariaDB server (foreground mode)..."
exec "$@"