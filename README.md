# TCE/RS Elastic stack

## Configuração

### Logstash

- _tcers/logstash/config/logstash.yml_: configurações gerais do _Logstash_
- _tcers/logstash/pipeline/*.conf_: pipelines do _Logstash_

### Elasticsearch 

- _tcers/elasticsearch/config/elasticsearch.yml_: configurações gerais do _Elasticsearch_

### Elasticsearch 

- _tcers/ikibana/config/kibana.yml_: configurações gerais do _Kibana_

### Beats

- _tcers/beats/metricbeat/config/metricbeat.yml_: configurações gerais do _Metricbeat_
- _tcers/beats/metricbeat/config/metricbeat-host.yml_: configurações gerais do _Metricbeat_ do host do container

- _tcers/beats/heartbeat/heartbeats/*.yml_: configurações dos heartbeats

## Instalação

Para instalar os arquivos de configuração:
 
_$ sudo /install.sh_

## Execução

Para executar a stack:

_$ sudo ./run.sh_

## Serviços

- elasticsearch
- logstash
- kibana
- metricbeat
- metricbeat-host
- hb-portal-internet
