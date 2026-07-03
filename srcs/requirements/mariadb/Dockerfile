FROM debian:bookworm

# =========================
# DEPENDENCIES
# =========================
# Install MariaDB server with minimal extra packages
RUN apt update && \
	apt install -y --no-install-recommends --no-install-suggests \
	mariadb-server \
	dos2unix && \
	rm -rf /var/lib/apt/lists/*

# =========================
# MYSQL RUNTIME SETUP
# =========================
# Create /var/run/mysqld directory and set correct permissions
# This is required for MariaDB to run properly
RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld

# =========================
# CONFIGURATION
# =========================
# Copy MariaDB configuration file
COPY conf/default.conf /etc/mysql/mariadb.conf.d/

# Copy initialization script
COPY tools/init-mariadb.sh /usr/local/bin/init-mariadb.sh
RUN dos2unix /usr/local/bin/init-mariadb.sh && chmod +x /usr/local/bin/init-mariadb.sh

# =========================
# EXPOSE PORT
# =========================
# MariaDB listens on port 3306 (internal network only)
# Not exposed to host - only accessible from WordPress container
EXPOSE 3306

# =========================
# USER
# =========================
# Run MariaDB as mysql user (non-root) for security
# (but entrypoint runs as root first to initialize, then switches to mysql)
USER root

# =========================
# STARTUP
# =========================
# Run initialization script first, then start MariaDB
ENTRYPOINT ["/usr/local/bin/init-mariadb.sh"]

# Start MariaDB server with explicit bind-address to listen on all interfaces
CMD ["mysqld", "--user=mysql", "--bind-address=0.0.0.0"]