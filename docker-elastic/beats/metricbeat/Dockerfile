ARG ELASTIC_VERSION
FROM docker.elastic.co/beats/metricbeat:$ELASTIC_VERSION

WORKDIR /usr/share/metricbeat

USER root

RUN yum -y install nc

RUN mkdir /var/log/metricbeat \
    && chown metricbeat /usr/share/metricbeat/metricbeat.yml \
    && chmod go-w /usr/share/metricbeat/metricbeat.yml \
    && chown metricbeat /var/log/metricbeat

COPY wait-for-hosts.sh /usr/local/bin/custom-entrypoint
RUN chmod +x /usr/local/bin/custom-entrypoint

USER metricbeat

ENTRYPOINT ["/usr/local/bin/custom-entrypoint"]
CMD ["./metricbeat", "-e"]
