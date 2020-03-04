# Some tips:
# https://linuxconfig.org/how-to-build-a-docker-image-using-a-dockerfile
#

FROM ubuntu:18.04

#ENV CW_DB_HOST host.docker.internal
#ENV CW_DB_NAME cw
#ENV CW_DB_PASSWORD test1234
#ENV CW_DB_USER sphinx

RUN apt-get update && apt-get install -y wget mysql-client-core-5.7 libmysqlclient-dev

RUN wget -q http://sphinxsearch.com/files/sphinx-3.1.1-612d99f-linux-amd64.tar.gz
RUN tar -zxf sphinx-3.1.1-612d99f-linux-amd64.tar.gz
RUN cp sphinx-3.1.1/bin/searchd /usr/bin
RUN cp sphinx-3.1.1/bin/indexer /usr/bin
RUN mkdir /etc/sphinxsearch

#COPY sphinxsearch /etc/init.d/sphinxsearch
COPY sphinx.config /etc/sphinxsearch/sphinx.config

# Create a new user
RUN useradd --create-home --shell /bin/bash sphinxsearch

USER sphinxsearch

RUN mkdir /home/sphinxsearch/logs
RUN mkdir /home/sphinxsearch/indexes
RUN mkdir /home/sphinxsearch/binlog

WORKDIR /home/sphinxsearch

USER root

#RUN /usr/bin/indexer --config /etc/sphinxsearch/sphinx.config --all

CMD /usr/bin/indexer --config /etc/sphinxsearch/sphinx.config --all && /usr/bin/searchd --config /etc/sphinxsearch/sphinx.config --nodetach
