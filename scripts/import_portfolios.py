import argparse
import pymongo
from bson.objectid import ObjectId
import contextlib
from datetime import datetime
from urllib import urlopen

from import_promed import import_promed

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-port', help="mongodb port", default=27017)
    parser.add_argument('-db', help="mongodb db", default="meteor")
    parser.add_argument('-url', help="meteor url", default="http://localhost:3000")
    args = parser.parse_args()

    meteor_url = args.url
    CKAN_URL = "https://ckan-datastore.s3.amazonaws.com/2013-12-05T16:54:56.230Z/portfolio-candidates-events.csv"

    portfolios_to_import = {}

    with contextlib.closing(urlopen(CKAN_URL)) as raw_csv:
        for line in raw_csv.read().split('\n')[1:]:
            if line:
                values = line.split(',')
                if '(' in values[0]:
                    name = "%s,%s" % (values[0], values[1])
                    promedId = values[3]
                    if not name in portfolios_to_import:
                        portfolios_to_import[name] = []
                    portfolios_to_import[name].append(promedId)

    db = pymongo.Connection('localhost', int(args.port))[args.db]
    portfolios = db.portfolios

    for name, resources in portfolios_to_import.iteritems():
        imported_resources = []
        for resource in resources:
            try:
                import_promed(db, resource)
                imported_resources.append(resource.split('.')[1])
                print "Imported %s" % resource
            except Exception as e:
                print "Error importing %s: %s" % (resource, e)


        portfolioId = portfolios.insert({
            '_id': str(ObjectId()),
            'name': name.replace('"', ''),
            'createDate': datetime.now(),
            'resources': imported_resources,
        })
