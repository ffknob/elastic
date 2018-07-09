#!/usr/bin/env python
# -*- coding: utf-8 -*-
from datetime import date
import re
import json
import codecs
import cx_Oracle
from elasticsearch import Elasticsearch

# Localhost
#es = Elasticsearch([{'host': 'localhost', 'port': 9200}])
# DSV
es = Elasticsearch([{'host': 'vmsrv103.tce.rs.gov.br', 'port': 80}])
# HMG
#es = Elasticsearch([{'host': 'vmsrv104.tce.rs.gov.br', 'port': 80}])
# PRD
#es = Elasticsearch([{'host': 'vmsrv96.tce.rs.gov.br', 'port': 80}])

conexao = {
    'usuario': 'tcers',
    'senha': 'alfr3d8',
    'servidor': 'ovmsrv04.tce.rs.gov.br',
    'servico': 'orades.tce.rs.gov.br'
}

indexes = [
    {   'prettyName': 'Súmulas', 'name': 'sumulas', 'index': 'jurisprudencia-sumulas', 'type': 'default', 'max': 1000,
        'data_file': 'jsons/V_SUMULAS.json', 'SQL': 'select * from pesquisa.v_sumulas' },
    {   'prettyName': 'Informações da Consultoria Técnica', 'name': 'informacoes-consultoria-tecnica', 'index': 'jurisprudencia-informacoes_ct', 'type': 'default', 'max': 1000,
        'data_file': 'jsons/V_INFORMACOES_CT.json', 'SQL': 'select * from pesquisa.v_informacoes_ct' },
    {   'prettyName': 'Pareceres da Auditoria/Consultoria', 'name': 'pareceres-auditoria-consultoria', 'index': 'jurisprudencia-pareceres', 'type': 'default', 'max': 1000,
        'data_file': 'jsons/V_PARECERES.json', 'SQL': 'select * from pesquisa.v_pareceres' },
    {   'prettyName': 'Decisões', 'name': 'decisoes', 'index': 'jurisprudencia-decisoes', 'type': 'default', 'max': 1000,
        'data_file': 'jsons/V_DECISOES-01.json', 'SQL': 'select * from pesquisa.v_decisoes' },

    {   'prettyName': 'Decisões/Relatores', 'name': 'decisoes-relatores', 'origem': 'MV_DECISOES_RELATORES', 'index': 'listas', 'type': 'default', 'max': 1000,
        'data_file': 'jsons/decisoes_relatores.json', 'SQL': 'select \'decisoes-relatores\' nome, \'MV_DECISOES_RELATORES\' origem, mdr.id_elasticsearch, mdr.cd_magistrado chave, mdr.nm_magistrado valor from pesquisa.mv_decisoes_relatores mdr' },
    {   'prettyName': 'Decisões/Órgãos', 'name': 'decisoes-orgaos', 'origem': 'MV_DECISOES_ORGAOS', 'index': 'listas', 'type': 'default', 'max': 1000,
        'data_file': 'jsons/decisoes_orgaos.json', 'SQL': 'select \'decisoes-orgaos\' nome, \'MV_DECISOES_ORGAOS\' origem, mdo.id_elasticsearch, mdo.cd_orgao chave, mdo.nm_orgao valor from pesquisa.mv_decisoes_orgaos mdo' },
    {   'prettyName': 'Decisões/Órgãos Julgadores', 'name': 'decisoes-orgaos-julgadores', 'origem': 'MV_DECISOES_ORGAOS_JULGADORES', 'index': 'listas', 'type': 'default', 'max': 1000,
        'data_file': 'jsons/decisoes_orgaos_julgadores.json', 'SQL': 'select \'decisoes-orgaos-julgadores\' nome, \'MV_DECISOES_ORGAOS_JULGADORES\' origem, mdoj.id_elasticsearch, mdoj.cd_orgao_julgador chave, mdoj.nm_orgao_julgador valor from pesquisa.mv_decisoes_orgaos_julgadores mdoj' },
    {   'prettyName': 'Decisões/Tipos Processos', 'name': 'decisoes-tipos-processos', 'origem': 'MV_DECISOES_TIPOS_PROCESSOS', 'index': 'listas', 'type': 'default', 'max': 1000,
        'data_file': 'jsons/decisoes_tipos_processos.json', 'SQL': 'select \'decisoes-tipos-processos\' nome, \'MV_DECISOES_TIPOS_PROCESSOS\' origem, mdtp.id_elasticsearch, mdtp.cd_magistrado chave, mdtp.nm_magistrado valor from pesquisa.mv_decisoes_tipos_processos mdtp' }
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

    print "{} -> {} total, {} sucessos, {} erros".format(index['prettyName'], total, sucessos, erros)
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

    print "{} -> {} total, {} sucessos, {} erros".format(index['prettyName'], total, sucessos, erros)

def transform_json(index):
    total = 0
    sucessos = 0
    erros = 0
    with codecs.open(index['data_file'], 'rU', 'utf-8') as f:
        data = json.loads(f.read())

    nf = open(index['data_file'] + '.transformed', 'w')
    for doc in data['items']:
        for attr in doc.keys():
            if(isinstance(doc[attr], basestring) and
                re.match('^[0-9]{2}/[0-9]{2}/[0-9]{2}$', doc[attr].encode('utf-8'))):
                day = doc[attr][0:2]
                month = doc[attr][3:5]
                year = doc[attr][6:8]

                if(int(year) >= 0 and int(year) <= 20):
                    year = '20' + year
                else:
                    year = '19' + year

                d = date(int(year), int(month), int(day))
                doc[attr] = d.strftime('%Y-%m-%d')

    json.dump(data, nf)

    print "{} -> {}".format(index['data_file'], index['data_file'] + '.transformed')

def main():
    string_conexao = conexao['usuario'] + '/' + \
                     conexao['senha'] + '@' + \
                     conexao['servidor'] + '/' + \
                     conexao['servico']

    #transform_json(indexes[0])
    #transform_json(indexes[1])
    #transform_json(indexes[2])
    #transform_json(indexes[3]) # Decisões

    #load_json(indexes[0]) # Súmulas
    #load_json(indexes[1]) # Informações da Consultoria Técnica
    #load_json(indexes[2]) # Pareceres da Auditoria/Consultoria
    #load_json(indexes[3]) # Decisões
    load_json(indexes[4]) # Decisões/Órgãos
    load_json(indexes[5]) # Decisões/Relatores
    load_json(indexes[6]) # Decisões/Órgãos Julgadores
    load_json(indexes[7]) # Decisões/Tipos Processos

'''
    print "Loading {}...".format(index['prettyName'])

    db = conectar(string_conexao)

    if db:
        load_oracle(indexes[3], db)
    else:
        print('Erro')

    db.close()
'''

if __name__ == '__main__':
    main()
