FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server

#create folder for the database process to run
RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld

#this line transports the conf to the container
COPY conf/default.conf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/init-mariadb.sh /usr/local/bin/mariadb-init.sh 

RUN chmod +x /usr/local/bin/mariadb-init.sh 

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mariadb-init.sh"]

#command that keeps container alive
CMD ["mysqld", "--user=mysql"]