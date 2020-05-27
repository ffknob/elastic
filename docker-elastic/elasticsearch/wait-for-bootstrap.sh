#!/bin/sh

set -e

CMD="$@"
ELASTICSEARCH_BOOTSTRAP_READY_FILE=/shared/bootstrap/bootstrap.ready

if [[ ! -f ${ELASTICSEARCH_BOOTSTRAP_READY_FILE} ]]
then
    >&2 echo "Elasticsearch bootstrap not ready yet. Waiting..."

    until [ -f ${ELASTICSEARCH_BOOTSTRAP_READY_FILE} ]
    do
      sleep 1
    done
fi

>&2 echo "Elasticsearch bootstrap finished."
exec ${CMD}
