import pymongo
import contextlib
from urllib import urlopen

db = pymongo.Connection('localhost', 3002)['meteor']

diseases = db.diseases

CKAN_URL = "https://ckan-datastore.s3.amazonaws.com/2013-11-12T18:22:32.991Z/google-define-disease-definitions.csv"

with contextlib.closing(urlopen(CKAN_URL)) as raw_csv:
	for line in raw_csv.read().split('\n')[1:]:
		if line:
			name, definition, synonyms = line.split(',')
			diseases.insert({
                'name': name.lower(),
                'definition': definition,
                'synonyms': [synonym.lower() for synonym in synonyms.split('  ') if synonym],
			})