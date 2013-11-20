import pymongo
import contextlib
import re
from urllib import urlopen

db = pymongo.Connection('localhost', 3002)['meteor']

tags = db.tags

DO_URL = 'https://svn.code.sf.net/p/diseaseontology/code/trunk/DO_logical_def.obo'

with contextlib.closing(urlopen(DO_URL)) as raw_obo:
	for term in raw_obo.read().split('\n[Typedef]')[0].split('\n[Term]\n')[1:]:
		category = None
		name = ''
		synonyms = []
		for line in term.split('\n'):
			if line.startswith('id: DOID:'):
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
					tags.insert({
						'name': symptom,
						'category': 'symptom',
						'source': 'disease ontology',
					})
		if category:
			for synonym in synonyms + [name]:
				tags.insert({
					'name': synonym.lower(),
					'category': category,
					'source': 'disease ontology',
				})