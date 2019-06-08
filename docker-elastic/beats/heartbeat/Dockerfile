ARG ELASTIC_VERSION 
FROM docker.elastic.co/beats/heartbeat:$ELASTIC_VERSION

WORKDIR /usr/share/heartbeat

USER root

RUN yum -y install nc

RUN mkdir /var/log/heartbeat \
    && chown heartbeat /usr/share/heartbeat/heartbeat.yml \
    && chmod go-w /usr/share/heartbeat/heartbeat.yml \
    && chown heartbeat /var/log/heartbeat

COPY wait-for-hosts.sh /usr/local/bin/custom-entrypoint
RUN chmod +x /usr/local/bin/custom-entrypoint

USER heartbeat

ENTRYPOINT ["/usr/local/bin/custom-entrypoint"]
CMD ["./heartbeat", "-e"]


