FROM debian:bookworm

RUN	apt update && \
	apt install -y --no-install-recommends --no-install-suggests \
	mariadb-server && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld

COPY  conf/default.conf /etc/mysql/mariadb.conf.d/
COPY tools/init-mariadb.sh /usr/local/bin/init-mariadb.sh

RUN chmod +x /usr/local/bin/init-mariadb.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/init-mariadb.sh"]

CMD ["mysqld", "--user=mysql"]