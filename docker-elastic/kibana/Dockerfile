ARG ELASTIC_VERSION
FROM docker.elastic.co/kibana/kibana:$ELASTIC_VERSION

COPY wait-for-bootstrap.sh /

USER kibana

CMD [ "/wait-for-bootstrap.sh", "/usr/local/bin/kibana-docker" ]
