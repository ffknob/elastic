#!/usr/bin/env python
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
    {   'index': 'jurisprudencia-sumulas', 'type': 'default',
        'SQL': 'select * from pesquisa.v_sumulas' },
    {   'index': 'jurisprudencia-informacoes_ct', 'type': 'default',
        'SQL': 'select * from pesquisa.v_informacoes_ct' },
    {   'index': 'jurisprudencia-pareceres', 'type': 'default',
        'SQL': 'select * from pesquisa.v_pareceres' },
    {   'index': 'jurisprudencia-decisoes', 'type': 'default',
        'SQL': 'select * from pesquisa.v_decisoes' }
]

def conectar(string_conexao):
    try:
        return cx_Oracle.connect(string_conexao, encoding='UTF-8', nencoding='UTF-8')
    except Exception as e:
        print('Erro: ' + str(e))
        return None

def load(index, db, quantidade = 50):
    cursor = db.cursor()
    cursor.execute(index['SQL'])

    total = 0
    sucessos = 0
    erros = 0
    for i in range(0, quantidade):
        total += 1

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
                    sucessos += 1

                except Exception as e:
                    erros += 1
                    print "[ERRO] {} -> {}: {}".format(index['index'], o['id_elasticsearch'], e)
                    continue
            else:
                break

        except Exception as e:
            erros += 1
            print "[ERRO] {}: {}".format(index['index'], e)

    print "{} -> {} total, {} sucessos, {} erros".format(index['index'], total, sucessos, erros)
    cursor.close()

def main():
    string_conexao = conexao['usuario'] + '/' + \
                     conexao['senha'] + '@' + \
                     conexao['servidor'] + '/' + \
                     conexao['servico']

    db = conectar(string_conexao)

    if db:
        load(indexes[0], db, 30)
    else:
        print('Erro')

    db.close()

if __name__ == '__main__':
    main()
