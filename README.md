# Elastic Stack

## Configuration

### Logstash

- _config/logstash/config/logstash.yml_: _Logstash_'s main configuration file
- _config/logstash/pipeline/*.conf_: _Logstash_'s pipelines

### Elasticsearch 

- _config/elasticsearch/config/elasticsearch.yml_: _Elasticsearch_'s main configuration file

### Kibana

- _config/kibana/config/kibana.yml_: _Kibana_'s maicn configuration file

### Beats

- _config/beats/metricbeat/config/metricbeat.yml_: _Metricbeat_'s general configuration (collects container's metrics)
- _config/beats/metricbeat/config/metricbeat-host.yml_: _Metricbeat_'s host configuration file (collects host's metrics)

- _config/beats/heartbeat/heartbeats/*.yml_: heartbeats

## Install

To install all the configuration files into the containers:
 
`$ ./elastic-ctl.sh install 7.2.0`

## Build

To build the containers:

`$ ./elastic-ctl.sh build`

You can also pass a specific version:

`$ ./elastic-ctl.sh build 7.2.0`

## Running

To start the stack:

`$ ./elastic-ctl.sh start 7.2.0`

You can also pass a specific version:

`$ ./elastic-ctl.sh start 7.2.0`

To stop the stack:

`$ ./elastic-ctl.sh stop`

## Services

- elasticsearch
- logstash
- kibana
- metricbeat
- metricbeat-host
- hb-portal-internet
