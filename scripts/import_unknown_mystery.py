import argparse
import pymongo
from bson.objectid import ObjectId
import contextlib
from datetime import datetime
from urllib import urlopen
import re

from import_promed import import_promed

report_id_regex = re.compile('\d{8}\.\d+')

def import_portfolio(db, ckan_url, title):
    portfolios_to_import = {}
    with contextlib.closing(urlopen(ckan_url)) as raw_csv:
        resourceIds = []
        for line in raw_csv.read().split('\n')[1:]:
            if line:
                report = line.split(',')[1]
                idMatch = report_id_regex.search(report)
                if idMatch:
                    id = idMatch.group(0)
                    resourceIds.append(id)

        portfolios_to_import[title] = {
            'resources': resourceIds,
        }
                
    portfolios = db.portfolios
    resources = db.resources

    print portfolios_to_import
    for name, info in portfolios_to_import.iteritems():
        imported_resources = []
        for resource in info['resources']:
            try:
                import_promed(db, resource)
                resourceId = resources.find_one({'promedId': resource}).get('_id')
                imported_resources.append(resourceId)
                print "Imported %s" % resource
            except Exception as e:
                print "Error importing %s: %s" % (resource, e)

        if not portfolios.find_one({'name': name}) and len(imported_resources) > 0:
            portfolioId = portfolios.insert({
                '_id': str(ObjectId()),
                'name': name,
                'disease': info.get('disease'),
                'location': info.get('location'),
                'year': info.get('year'),
                'createDate': datetime.now(),
                'resources': imported_resources,
            })
            print "Imported %s" % name



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-port', help="mongodb port", default=27017)
    parser.add_argument('-db', help="mongodb db", default="meteor")
    args = parser.parse_args()

    db = pymongo.Connection('localhost', int(args.port))[args.db]
    MYSTERY_CKAN_URL = "https://ckan-datastore.s3.amazonaws.com/2014-01-14T22:56:19.439Z/mystery-promed-news.csv"
    UNKNOWN_CKAN_URL = "https://ckan-datastore.s3.amazonaws.com/2014-01-14T22:57:08.225Z/unknown-promed-news.csv"

    import_portfolio(db, MYSTERY_CKAN_URL, 'Mystery ProMED reports')
    import_portfolio(db, UNKNOWN_CKAN_URL, 'Unknown ProMED reports')
