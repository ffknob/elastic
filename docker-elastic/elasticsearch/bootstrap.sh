#!/bin/bash

mkdir -p /shared/bootstrap/

if [[ ! -f /shared/certfificates.ready ]]; then
  if [[ ! -f /certs/ca.zip  ]]; then
    echo "Generating CA"
    ./bin/elasticsearch-certutil ca --silent --pass ${CA_PASSWORD} --pem --out /certs/ca.zip
    unzip /certs/ca.zip -d /certs > /dev/null
    touch /shared/bootstrap/ca_cert.ready
  fi

  if [[ ! -f /certs/elasticsearch01.p12 ]]; then
    echo "Generating certificate for Elasticsearch01"
    ./bin/elasticsearch-certutil cert --silent --ca-cert /certs/ca/ca.crt --ca-key /certs/ca/ca.key --ca-pass ${CA_PASSWORD} --pass ${ELASTICSEARCH01_CERT_PASSWORD} --dns elasticsearch01 --out /certs/elasticsearch01.p12
    touch /shared/bootstrap/elasticsearch01_cert.ready
  fi

  if [[ ! -f /certs/elasticsearch02.p12 ]]; then
    echo "Generating certificate for Elasticsearch02"
    ./bin/elasticsearch-certutil cert --silent --ca-cert /certs/ca/ca.crt --ca-key /certs/ca/ca.key --ca-pass ${CA_PASSWORD} --pass ${ELASTICSEARCH02_CERT_PASSWORD} --dns elasticsearch02 --out /certs/elasticsearch02.p12
    touch /shared/bootstrap/elasticsearch02_cert.ready
  fi

  if [[ ! -f /certs/elasticsearch03.p12 ]]; then
    echo "Generating certificate for Elasticsearch03"
    ./bin/elasticsearch-certutil cert --silent --ca-cert /certs/ca/ca.crt --ca-key /certs/ca/ca.key --ca-pass ${CA_PASSWORD} --pass ${ELASTICSEARCH02_CERT_PASSWORD} --dns elasticsearch03 --out /certs/elasticsearch03.p12
    touch /shared/bootstrap/elasticsearch03_cert.ready
  fi

  if [[ ! -f /certs/kibana.zip ]]; then
    echo "Generating certificate for Kibana"
    ./bin/elasticsearch-certutil cert --silent --ca-cert /certs/ca/ca.crt --ca-key /certs/ca/ca.key --ca-pass ${CA_PASSWORD} --pass ${KIBANA_CERT_PASSWORD} --pem --dns kibana --out /certs/kibana.zip
    unzip /certs/kibana.zip -d /certs > /dev/null
    mv /certs/instance/instance.crt /certs/kibana.crt
    mv /certs/instance/instance.key /certs/kibana.key
    rm -rf /certs/instance
    touch /shared/bootstrap/kibana_cert.ready
  fi

  chown -R elasticsearch:root /certs

  touch /shared/bootstrap/certificates.ready
fi;

if [[ ! -f /shared/built_in_users.ready ]]; then
  if [[ ! -f ./config/elasticsearch.keystore ]]; then
    echo "Creating keystore"
    ./bin/elasticsearch-keystore create > /dev/null
  fi

  ./bin/elasticsearch-keystore list | grep bootstrap.password > /dev/null
  if [[ $? -ne 0 ]]; then
    echo "Adding elastic user bootstrap password"
    echo ${ELASTIC_USER_PASSWORD} | ./bin/elasticsearch-keystore add --stdin bootstrap.password > /dev/null
  fi

  echo "Starting Elasticsearch"
  su elasticsearch -c "./bin/elasticsearch -d -p pid"

  echo "Waiting for Elasticsearch to startup"
  ELASTICSEARCH_CONNECTION_TRY=1
  while true
  do
    echo "Trying to connect to Elasticsearch... (${ELASTICSEARCH_CONNECTION_TRY})"
    curl -s -o /shared/bootstrap/elasticsearch_startup.status http://localhost:9200/_cluster/health\?filter_path\=timed_out\&timeout\=30s\&wait_for_nodes\=1 -k -u elastic:${ELASTIC_USER_PASSWORD}

    if [[ $? -eq 0 ]]; then
      break
    else
      ELASTICSEARCH_CONNECTION_TRY=`expr ${ELASTICSEARCH_CONNECTION_TRY} + 1`
      sleep 1
    fi
  done

  grep -c "true" /shared/bootstrap/elasticsearch_startup.status > /dev/null
  if [[ $? -eq 0 ]]; then
    echo "Elasticsearch did not came up after 30 seconds. Aborting."
    exit -1
  fi

  if [[ ! -f /shared/bootstrap/built-in_users-elastic.ready ]]; then
    echo "Setting elastic user password"
    curl -s -XPOST -H"Content-type: application/json" http://localhost:9200/_security/user/elastic/_password -k -u elastic:${ELASTIC_USER_PASSWORD} -d'{ "password": "'${ELASTIC_USER_PASSWORD}'"}'
    touch /shared/bootstrap/built-in_users-elastic.ready
  fi

  if [[ ! -f /shared/bootstrap/built-in_users-kibana.ready ]]; then
   echo "Setting kibana user password"
    curl -s -XPOST -H"Content-type: application/json" http://localhost:9200/_security/user/kibana/_password -k -u elastic:${ELASTIC_USER_PASSWORD} -d'{ "password": "'${KIBANA_USER_PASSWORD}'"}'
    touch /shared/bootstrap/built-in_users-kibana-ready
  fi

  if [[ ! -f /shared/bootstrap/built-in_users-logstash_system.ready ]]; then
    echo "Setting logstash_system user password"
    curl -s -XPOST -H"Content-type: application/json" http://localhost:9200/_security/user/logstash_system/_password -k -u elastic:${ELASTIC_USER_PASSWORD} -d'{ "password": "'${LOGSTASH_SYSTEM_USER_PASSWORD}'"}'
    touch /shared/bootstrap/built-in_users-logstash_system.ready
  fi

  if [[ ! -f /shared/bootstrap/built-in_users-beats_system.ready ]]; then
    echo "Setting beats_system user password"
    curl -s -XPOST -H"Content-type: application/json" http://localhost:9200/_security/user/beats_system/_password -k -u elastic:${ELASTIC_USER_PASSWORD} -d'{ "password": "'${BEATS_SYSTEM_USER_PASSWORD}'"}'
    touch /shared/bootstrap/built-in_users-beat_system.ready
  fi

  if [[ ! -f /shared/bootstrap/built-in_users-apm_system.ready ]]; then
    echo "Setting apm_system user password"
    curl -s -XPOST -H"Content-type: application/json" http://localhost:9200/_security/user/apm_system/_password -k -u elastic:${ELASTIC_USER_PASSWORD} -d'{ "password": "'${APM_SYSTEM_USER_PASSWORD}'"}'
    touch /shared/bootstrap/built-in_users-apm_system.ready
  fi

  if [[ ! -f /shared/bootstrap/built-in_users-remote_monitoring_user.ready ]]; then
    echo "Setting remote_monitoring_user user password"
    curl -XPOST -H"Content-type: application/json" http://localhost:9200/_security/user/remote_monitoring_user/_password -k -u elastic:${ELASTIC_USER_PASSWORD} -d'{ "password": "'${REMOTE_MONITORING_USER_PASSWORD}'"}'
    touch /shared/bootstrap/built-in_users-remote_monitoring_user.ready
  fi

  touch /shared/bootstrap/built-in_users.ready

  echo "Stopping Elasticsearch"
  kill -9 `cat pid`

fi;

touch /shared/bootstrap/bootstrap.ready
