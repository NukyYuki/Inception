FROM debian:bookworm

# Install Nginx and OpenSSL
RUN apt-get update && apt-get install -y nginx openssl

#remove default configuration from debian
RUN rm -rf /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default

#set up SSL folder
RUN mkdir -p /etc/nginx/ssl

# Generate self-signed SSL certificate
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=PT/ST=Porto/L=Porto/O=42/OU=42/CN=mipinhei.42.fr/UID=mipinhei"

#configure NGINX
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

#start service
CMD [ "nginx", "-g", "daemon off;" ]