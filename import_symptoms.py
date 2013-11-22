import pymongo
import contextlib
from urllib import urlopen

db = pymongo.Connection('localhost', 3002)['meteor']

tags = db.tags

CKAN_URL = "https://ckan-datastore.s3.amazonaws.com/2013-11-12T18:19:11.105Z/medicinenet-symptom-definitions.csv"

with contextlib.closing(urlopen(CKAN_URL)) as raw_csv:
    for line in raw_csv.read().split('\n')[1:]:
        if line:
            name, definition, source = line.split(',')
            if not tags.find_one({'name': name.lower()}):
                tags.insert({
                    'name': name.lower(),
                    'category': 'symptom',
                })