#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import codecs
import cx_Oracle
from elasticsearch import Elasticsearch

es = Elasticsearch([{'host': 'localhost', 'port': 9200}])

conexao = {
    'usuario': 'tcers',
    'senha': 'alfr3d8',
    'servidor': 'ovmsrv04.tce.rs.gov.br',
    'servico': 'orades.tce.rs.gov.br'
}

indexes = [
    {   'name': 'Súmulas', 'index': 'jurisprudencia-sumulas', 'type': 'default', 'max': 1000,
        'data_file': 'jsons/V_SUMULAS.json',
        'SQL': 'select * from pesquisa.v_sumulas' },
    {   'name': 'Informações da Consultoria Técnica', 'index': 'jurisprudencia-informacoes_ct', 'type': 'default', 'max': 1000,
        'data_file': 'jsons/V_INFORMACOES_CT.json',
        'SQL': 'select * from pesquisa.v_informacoes_ct' },
    {   'name': 'Pareceres da Auditoria/Consultoria', 'index': 'jurisprudencia-pareceres', 'type': 'default', 'max': 1000,
        'data_file': 'jsons/V_PARECERES.json',
        'SQL': 'select * from pesquisa.v_pareceres' },
    {   'name': 'Decisões', 'index': 'jurisprudencia-decisoes', 'type': 'default', 'max': 1000,
        'data_file': 'jsons/V_DECISOES-01.json',
        'SQL': 'select * from pesquisa.v_decisoes' },
    {   'name': 'Conselheiros relatores', 'index': 'listas', 'type': 'default', 'max': 1000,
        'data_file': 'jsons/conselheiros_relatores.json',
        'SQL': 'select * from pesquisa.v_conselheiros_relatores' },
    {   'name': 'Órgãos julgadores', 'index': 'listas', 'type': 'default', 'max': 1000,
        'data_file': 'jsons/orgaos_julgadores.json',
        'SQL': 'select * from pesquisa.v_orgaos_julgadores' },
    {   'name': 'Tipos de processos', 'index': 'listas', 'type': 'default', 'max': 1000,
        'data_file': 'jsons/tipos_processos.json',
        'SQL': 'select * from pesquisa.v_tipos_processos' }
]

def conectar(string_conexao):
    try:
        return cx_Oracle.connect(string_conexao, encoding='UTF-8', nencoding='UTF-8')
    except Exception as e:
        print('Erro: ' + str(e))
        return None

def load_oracle(index, db):
    cursor = db.cursor()
    cursor.execute(index['SQL'])

    total = 0
    sucessos = 0
    erros = 0
    for i in range(0, index['max']):
        try:
            row = cursor.fetchone()

            if row:
                o = {}
                for c in range(0, len(cursor.description)):
                    if row[c]:
                        o[cursor.description[c][0].lower()] = row[c]

                try:
                    #print repr(json.dumps(o, indent=4, sort_keys=True, default=str))
                    es.index(index=index['index'], doc_type=index['type'], id=o['id_elasticsearch'], body=json.dumps(o, indent=4, sort_keys=True, default=str))
                    total += 1
                    sucessos += 1

                except Exception as e:
                    total += 1
                    erros += 1
                    print "[ERRO] {} -> {}: {}".format(index['index'], o['id_elasticsearch'], e)
                    continue
            else:
                break

        except Exception as e:
            total += 1
            erros += 1
            print "[ERRO] {}: {}".format(index['index'], e)

    print "{} -> {} total, {} sucessos, {} erros".format(index['name'], total, sucessos, erros)
    cursor.close()

def load_json(index):
    total = 0
    sucessos = 0
    erros = 0
    with codecs.open(index['data_file'], 'rU', 'utf-8') as f:
        data = json.loads(f.read())

    for doc in data['items']:
        id = doc['id_elasticsearch']

        try:
            es.index(index=index['index'], doc_type=index['type'], id=id, body=doc)
            total += 1
            sucessos += 1

        except Exception as e:
            print "{} -> {}: ERROR {}".format(index["index"], id, e)
            total += 1
            erros += 1
            continue

    print "{} -> {} total, {} sucessos, {} erros".format(index['name'], total, sucessos, erros)

def main():
    string_conexao = conexao['usuario'] + '/' + \
                     conexao['senha'] + '@' + \
                     conexao['servidor'] + '/' + \
                     conexao['servico']

    #load_json(indexes[0])
    load_json(indexes[1])
    load_json(indexes[2])
    load_json(indexes[3])
'''
    print "Loading {}...".format(index['name'])

    db = conectar(string_conexao)

    if db:
        load_oracle(indexes[3], db)
    else:
        print('Erro')

    db.close()
'''

if __name__ == '__main__':
    main()
