import pymongo
import contextlib
import argparse
import re
from urllib import urlopen

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-port', help="mongodb port", default=27017)
    parser.add_argument('-db', help="mongodb db", default="meteor")
    args = parser.parse_args()

    db = pymongo.Connection('localhost', int(args.port))[args.db]

    tags = db.tags

    DO_URL = 'https://svn.code.sf.net/p/diseaseontology/code/trunk/DO_logical_def.obo'

    with contextlib.closing(urlopen(DO_URL)) as raw_obo:
        text = raw_obo.read()
        is_a_doid_regex = re.compile('is_a: DOID:(\d+)')
        disease_category_ids = set()
        for line in text.split('\n'):
            if line.startswith('is_a: DOID'):
                try:
                    doid = is_a_doid_regex.match(line).group(1)
                    disease_category_ids.add(doid)
                except:
                    print 'error: %s' % line

        doid_regex = re.compile('id: DOID:(\d+)')
        for term in text.split('\n[Typedef]')[0].split('\n[Term]\n')[1:]:
            category = None
            name = ''
            synonyms = []
            for line in term.split('\n'):
                if line.startswith('id: DOID:'):
                    doid = doid_regex.match(line).group(1)
                    if doid in disease_category_ids:
                        category = 'disease category'
                    else:
                        category = 'disease'
                elif line.startswith('id: SYMP:'):
                    category = 'symptom'
                elif line.startswith('name:'):
                    name = line.split(': ')[1]
                elif line.startswith('synonym: '):
                    synonyms.append(line.split('"')[1])
                elif line.startswith('def: '):
                    symptoms = [re.compile('[\w\s]*').match(text).group(0) for text in line.split('has_symptom ')[1:]]
                    for symptom in symptoms:
                        if not tags.find_one({'name': symptom}):
                            tags.insert({
                                'name': symptom,
                                'category': 'symptom',
                                'source': 'disease ontology',
                            })
            if category:
                for synonym in synonyms + [name]:
                    if not tags.find_one({'name': synonym}):
                        tags.insert({
                            'name': synonym.lower(),
                            'category': category,
                            'source': 'disease ontology',
                        })