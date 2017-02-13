FROM mongo:3.2.8
RUN mkdir /data/backups && chown -R mongodb:mongodb /data/backups
COPY init-cluster.sh /
#COPY mongodb-keyfile /opt/keyfile/
#RUN apt-get update && \ 
#    apt-get install nano -y && \
#    chown 999 /opt/keyfile/mongodb-keyfile


