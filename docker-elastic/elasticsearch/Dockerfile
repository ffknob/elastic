ARG ELASTIC_VERSION
FROM docker.elastic.co/elasticsearch/elasticsearch:$ELASTIC_VERSION

COPY bootstrap.sh /
COPY wait-for-bootstrap.sh /

USER elasticsearch

CMD [ "/wait-for-bootstrap.sh", "/usr/local/bin/docker-entrypoint.sh" ]
