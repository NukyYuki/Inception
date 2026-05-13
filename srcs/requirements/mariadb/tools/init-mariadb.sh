#!/bin/bash

#start mariadb server and create database
set -e

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db
fi

echo "Starting MariaDB server Config"

mysql_safe &
MARIADB_PID=$!

# Wait for the server to start
for i in {30..0}; do
    if mysqladmin ping --silent; then
        echo "MariaDB server is up and running!"
        break
    fi
    if [ $i -eq 0 ]; then
        echo "MariaDB server failed to start."
        exit 1
    fi
    echo "Waiting for MariaDB server to start... ($i seconds left)"
    sleep 1
done

if ! [ -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "Creating database and users"

    mysql -u root << EOF
    --set password for root user
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

    --create database
    CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

    --create user
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

    --grant privileges to user
    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

    --flush privileges;
    FLUSH PRIVILEGES;
EOF
echo "Database and user created successfully!"
else
    echo "Database already exists. Skipping initialization."

mysql -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
fi

echo "Shutting down MariaDB server... And Restarting"
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown 2> /dev/null || true

wait $MARIADB_PID 2> /dev/null || true

echo "Starting MariaDB server"
exec "$@"