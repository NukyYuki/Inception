FROM debian:bookworm

# =========================
# DEPENDENCIES
# =========================
RUN apt-get update && apt-get install -y nginx openssl

# =========================
# CONFIGURATION CLEANUP
# =========================
# Remove default Debian nginx configuration
RUN rm -rf /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default

# =========================
# SSL SETUP
# =========================
# Create SSL directory for HTTPS certificates
RUN mkdir -p /etc/nginx/ssl

# Generate self-signed SSL certificate for the Inception project
# Uses DOMAIN_NAME from environment (mipinhei.42.fr for 42 School)
RUN openssl req -x509 -nodes \
	-out /etc/nginx/ssl/inception.crt \
	-keyout /etc/nginx/ssl/inception.key \
	-subj "/C=PT/ST=Porto/L=Porto/O=42/OU=42/CN=${DOMAIN_NAME}"

# =========================
# NGINX CONFIGURATION
# =========================
# Copy custom nginx configuration
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# =========================
# STARTUP
# =========================
# Run NGINX in foreground to keep container alive
CMD [ "nginx", "-g", "daemon off;" ]