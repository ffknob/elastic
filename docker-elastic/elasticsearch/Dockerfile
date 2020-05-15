ARG ELASTIC_VERSION
FROM docker.elastic.co/elasticsearch/elasticsearch:$ELASTIC_VERSION

COPY bootstrap.sh /
COPY wait-for-bootstrap.sh /

CMD [ "/wait-for-bootstrap.sh", "/usr/share/bin/elasticsearch" ]
