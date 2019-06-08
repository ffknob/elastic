#!/bin/bash

use() {

	echo "${0} install|build [ELASTIC_VERSION]|start [ELASTIC_VERSION]|stop"
	echo "	install		installs configuration files for the containers"
	echo "	start		starts the stack"
	echo "	stop		stops the stack"

	exit -1
}

install() {
	# Elasticsearch
	chown 1000:1000 docker-elastic/elasticsearch/data/
	cp -f config/elasticsearch/elasticsearch.yml docker-elastic/elasticsearch/config/elasticsearch.yml 2> /dev/null

	# Logstash
	cp -f config/logstash/logstash.yml docker-elastic/logstash/config/logstash.yml 2> /dev/null
	#cp -f config/logstash/pipeline/*.yml docker-elastic/logstash/pipeline/ 2> /dev/null

	# Kibana
	cp -f config/kibana/kibana.yml docker-elastic/kibana/config/kibana.yml 2> /dev/null

	# Metricbeat
	cp -f config/beats/metricbeat/metricbeat.yml docker-elastic/beats/metricbeat/config/metricbeat.yml 2> /dev/null
	cp -f config/beats/metricbeat/metricbeat-host.yml docker-elastic/beats/metricbeat/config/metricbeat-host.yml 2> /dev/null

	# Heartbeat
	cp -f config/beats/heartbeat/heartbeats/*.yml docker-elastic/beats/heartbeat/heartbeats/ 2> /dev/null
}

build() {
	cd docker-elastic/
	if [ -z "${1}" ]
	then
		docker-compose build
	else
		ELASTIC_VERSION=${1} docker-compose build
	fi
}

start() {
	cd docker-elastic/
	if [ -z "${1}" ]
	then
		docker-compose up -d
	else
		ELASTIC_VERSION=${1} docker-compose up -d
	fi
}

stop() {
	cd docker-elastic/
	docker-compose down
}

if [ $# -eq 0 ]
then
	use
fi

case "${1}" in
	"install")
		install
		;;
	"build")
		build ${2}
		;;
	"start")
		start ${2}
		;;
	"stop")
		stop
		;;
	*)
		echo "Error: Command not recognized."
		use
		exit -1
		;;
esac	
