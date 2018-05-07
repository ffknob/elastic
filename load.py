#!/usr/bin/env python
import json
import codecs
from elasticsearch import Elasticsearch

es = Elasticsearch([{'host': 'localhost', 'port': 9200}])

indexes = [
    { 'data_file': 'V_SUMULAS.json', 'index': 'jurisprudencia-sumulas', 'type': 'default'},
    { 'data_file': 'V_INFORMACOES_CT.json', 'index': 'jurisprudencia-informacoes_ct', 'type': 'default'},
    { 'data_file': 'V_PARECERES.json', 'index': 'jurisprudencia-pareceres', 'type': 'default'},
    { 'data_file': 'V_DECISOES-01.json', 'index': 'jurisprudencia-decisoes', 'type': 'default'}
]

for index in indexes:
    print "Loading {}...".format(index["index"])
    total_ok = 0
    total_error = 0

    with codecs.open(index["data_file"], 'rU', 'utf-8') as f:
        data = json.loads(f.read())

    for doc in data["items"]:
        id = doc["id_elasticsearch"]

        try:
            es.index(index=index["index"], doc_type=index["type"], id=id, body=doc)

            #print "{} -> {}: OK".format(index["index", id)
            total_ok += 1

        except Exception as e:
            #print "{} -> {}: ERROR".format(index["index"], id)
            total_error += 1
            continue

    print "OK: {}".format(total_ok)
    print "Error: {}".format(total_error)
