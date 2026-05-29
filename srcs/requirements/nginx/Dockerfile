FROM debian:bookworm

#install nginx and openssl (openssl is used to generate the security certificates)
RUN apt-get update && apt-get install -y nginx openssl

#removes default configuration from debian
RUN rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default

#set up the SSL folder (to store the keys for the http connection)
RUN mkdir -p /etc/nginx/ssl

#generate the certificate (passport for the website)
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=PT/ST=Porto/L=Porto/O=42/OU=42/CN=dda-fons.42.fr/UID=dda-fons"

#configure NGINX (copy the custom config into the container)
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

#start NGINX (in the foreground with daemon off so the container doesn't close)
CMD [ "nginx", "-g", "daemon off;" ]