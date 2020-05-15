#!/bin/bash
if [[ ! -f /shared/certfificates.ready ]]; then
  echo "[Generating CA]"
  bin/elasticsearch-certutil ca --silent --pass ${CA_PASSWORD} --pem --out /certs/ca.zip
  unzip /certs/ca.zip -d /certs

  echo "[Generating certificate for Elasticsearch01]"
  bin/elasticsearch-certutil cert --silent --ca-cert /certs/ca/ca.crt --ca-key /certs/ca/ca.key --ca-pass ${CA_PASSWORD} --pass ${ELASTICSEARCH01_CERT_PASSWORD} --dns elasticsearch01 --out /certs/elasticsearch01.p12

  echo "[Generating certificate for Elasticsearch02]"
  bin/elasticsearch-certutil cert --silent --ca-cert /certs/ca/ca.crt --ca-key /certs/ca/ca.key --ca-pass ${CA_PASSWORD} --pass ${ELASTICSEARCH02_CERT_PASSWORD} --dns elasticsearch02 --out /certs/elasticsearch02.p12

  echo "[Generating certificate for Elasticsearch03]"
  bin/elasticsearch-certutil cert --silent --ca-cert /certs/ca/ca.crt --ca-key /certs/ca/ca.key --ca-pass ${CA_PASSWORD} --pass ${ELASTICSEARCH02_CERT_PASSWORD} --dns elasticsearch03 --out /certs/elasticsearch03.p12

  echo "[Generating certificate for Kibana]"
  bin/elasticsearch-certutil cert --silent --ca-cert /certs/ca/ca.crt --ca-key /certs/ca/ca.key --ca-pass ${CA_PASSWORD} --pass ${KIBANA_CERT_PASSWORD} --pem --dns kibana --out /certs/kibana.zip
  unzip /certs/kibana.zip -d /certs
  mv /certs/instance/instance.crt /certs/kibana.crt
  mv /certs/instance/instance.key /certs/kibana.key
  rm -rf /certs/instance

  chown -R 1000:0 /certs

  touch /shared/certificates.ready
fi;

if [[ ! -f /shared/built_in_users.ready ]]; then
  echo "[Creating keystore]"
  ./bin/elasticsearch-keystore create

  echo "[Adding elastic user bootstrap password]"
  echo ${ELASTIC_USER_PASSWORD} | ./bin/elasticsearch-keystore add --stdin bootstrap.password

  echo "[Starting Elasticsearch]"
  ./bin/elasticsearch -d -p pid

  curl -s -o /shared/elasticsearch_startup.status https://localhost:9200/_cluster/health\?filter_path\=timed_out\&timeout\=30s\&wait_for_nodes\=1 -k -u elastic:${ELASTIC_USER_PASSWORD}

  ELASTICSEARCH_STARTUP_TIMED_OUT=`grep -c true /shared/elasticsearch_startup.status`
  if [[ ${ELASTICSEARCH_STARTUP_TIMED_OUT} -eq 0 ]]; then
    echo "Elasticsearch did not came up after 30 seconds. Aborting."
    exit -1
  fi

  echo "[Setting elastic user password]"
  curl -XPOST -H"Content-type: application/json" https://localhost:9200/_security/user/elastic/_password -k -u elastic:${ELASTIC_USER_PASSWORD} -d'{ "password": "'${ELASTIC_USER_PASSWORD}'"}'

  echo "[Setting kibana user password]"
  curl -XPOST -H"Content-type: application/json" https://localhost:9200/_security/user/kibana/_password -k -u elastic:${ELASTIC_USER_PASSWORD} -d'{ "password": "'${KIBANA_USER_PASSWORD}'"}'

  echo "[Setting logstash_system user password]"
  curl -XPOST -H"Content-type: application/json" https://localhost:9200/_security/user/logstash_system/_password -k -u elastic:${ELASTIC_USER_PASSWORD} -d'{ "password": "'${LOGSTASH_SYSTEM_USER_PASSWORD}'"}'

  echo "[Setting beats_system user password]"
  curl -XPOST -H"Content-type: application/json" https://localhost:9200/_security/user/beats_ystem/_password -k -u elastic:${ELASTIC_USER_PASSWORD} -d'{ "password": "'${BEATS_SYSTEM_USER_PASSWORD}'"}'

  echo "[Setting apm_system user password]"
  curl -XPOST -H"Content-type: application/json" https://localhost:9200/_security/user/apm_system/_password -k -u elastic:${ELASTIC_USER_PASSWORD} -d'{ "password": "'${APM_SYSTEM_USER_PASSWORD}'"}'

  echo "[Setting remote_monitoring_user user password]"
  curl -XPOST -H"Content-type: application/json" https://localhost:9200/_security/user/remote_monitoring_user/_password -k -u elastic:${ELASTIC_USER_PASSWORD} -d'{ "password": "'${REMOTE_MONITORING_USER_PASSWORD}'"}'

  echo "[Stopping Elasticsearch]"
  kill -9 `cat pid`

  touch /shared/built_in_users.ready
fi;

touch /shared/bootstrap.ready
