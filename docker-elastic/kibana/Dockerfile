ARG ELASTIC_VERSION
FROM docker.elastic.co/kibana/kibana:$ELASTIC_VERSION

COPY wait-for-bootstrap.sh /

CMD [ "/wait-for-bootstrap.sh", "/usr/share/bin/kibana" ]
