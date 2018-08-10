#!/bin/bash

# Elasticsearch
chown 1000:1000 docker-elk/elasticsearch/data/
cp -f tcers/elasticsearch/config/elasticsearch.yml docker-elk/elasticsearch/config/elasticsearch.yml

# Logstash
cp -f tcers/logstash/config/logstash.yml docker-elk/logstash/config/logstash.yml
#cp -f tcers/logstash/pipeline/*.yml docker-elk/logstash/pipeline/ 

# Kibana
cp -f tcers/kibana/config/kibana.yml docker-elk/kibana/config/kibana.yml

# Metricbeat
cp -f tcers/beats/metricbeat/config/metricbeat.yml docker-elk/beats/metricbeat/config/metricbeat.yml 
cp -f tcers/beats/metricbeat/config/metricbeat-host.yml docker-elk/beats/metricbeat/config/metricbeat-host.yml 

# Heartbeat
cp -f tcers/beats/heartbeat/heartbeats/*.yml docker-elk/beats/heartbeat/heartbeats/ 
