import pymongo
import contextlib
import argparse
from urllib import urlopen

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-port', help="mongodb port", default=27017)
    parser.add_argument('-db', help="mongodb db", default="meteor")
    args = parser.parse_args()

    db = pymongo.Connection('localhost', int(args.port))[args.db]

    tags = db.tags

    CKAN_URL = "https://ckan-datastore.s3.amazonaws.com/2013-11-12T18:22:32.991Z/google-define-disease-definitions.csv"

    with contextlib.closing(urlopen(CKAN_URL)) as raw_csv:
        for line in raw_csv.read().split('\n')[1:]:
            if line:
                name, definition, synonyms = line.split(',')
                for synonym in synonyms.split('  ') + [name]:
                    if synonym:
                        if not tags.find_one({'name': synonym.lower()}):
                            tags.insert({
                                'name': synonym.lower(),
                                'category': 'disease',
                            })