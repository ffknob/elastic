#!/bin/bash

use() {

	echo "${0} build [ELASTIC_VERSION]|start [ELASTIC_VERSION]|stop"
	echo "	build		builds the containers"
	echo "	start		starts the stack"
	echo "	stop		stops the stack"

	exit -1
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
		docker-compose stop
		docker-compose up -d
	else
		ELASTIC_VERSION=${1} docker-compose down
		ELASTIC_VERSION=${1} docker-compose up -d
	fi
}

stop() {
	cd docker-elastic/
	if [ -z "${1}" ]
	then
		docker-compose down
	else
		ELASTIC_VERSION=${1} docker-compose down
	fi
}

if [ $# -eq 0 ]
then
	use
fi

case "${1}" in
	"install")
		install ${2}
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
