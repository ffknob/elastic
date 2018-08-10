#!/usr/bin/env bash

wait_single_host() {
  local host=$1
  shift
  local port=$1
  shift

  echo "==> Verificando ${host}:${port}"
  echo -n "   --> Aguardando por ${host}:${port} "
  while ! nc ${host} ${port} > /dev/null 2>&1 < /dev/null; do echo -n "." && sleep 1; done;
  echo ""
}

wait_all_hosts() {
  if [ ! -z "$WAIT_FOR_HOSTS" ]; then
    local separator=':'
    for _HOST in $WAIT_FOR_HOSTS ; do
        IFS="${separator}" read -ra _HOST_PARTS <<< "$_HOST"
        wait_single_host "${_HOST_PARTS[0]}" "${_HOST_PARTS[1]}"
    done
  fi
}

wait_all_hosts

echo -n "==> Aguardando status YELLOW do cluster Elasticsearch"
while ! curl -s -X GET ${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_cluster/health\?wait_for_status\=yellow\&timeout\=60s | grep -q '"status":"yellow"'
do
    echo -n "." && sleep 1
done

echo ""
echo "==> Status YELLOW"
echo ""

exec "$@"
