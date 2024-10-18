ARG VERSION
FROM mariadb:$VERSION

RUN apt-get update && \
	apt-get install -y cron && \
	apt-get clean

RUN mkdir /backup

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY mysqldump.cron /etc/cron.d/mysqldump.cron

RUN crontab /etc/cron.d/mysqldump.cron

ENTRYPOINT ["/entrypoint.sh"]
CMD ["mariadbd"]
