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
    CKAN_URL = "https://ckan-datastore.s3.amazonaws.com/2014-01-10T17:12:08.841Z/portfolio-candidates-events-1.csv"

    portfolios_to_import = {}

    with contextlib.closing(urlopen(CKAN_URL)) as raw_csv:
        for line in raw_csv.read().split('\n')[1:]:
            if line and not line.startswith(','):
                values = line.split(',')
                if '(' in values[0] and not values[1].startswith('http'):
                    name = "%s,%s" % (values[0], values[1])
                    name = name.replace('"', '').strip()
                    print "%s already imported" % name
                else:
                    name = values[0]
                    isEncephIndia = False
                    if name == 'Encephalidities (India)':
                        isEncephIndia = True
                        name = values[2]
                        i = 3
                        while (len(values) > i + 1) and values[i] != '':
                            name += values[i]
                            i = i + 1
                        name = name.replace('"', '')
                    if not name in portfolios_to_import:
                        if isEncephIndia:
                                portfolios_to_import[name] = {
                                    'resources': [],
                                }
                        elif '(' in name:
                            disease, details = name.replace(')', '').split('(')
                            if ',' in details:
                                location, year = details.split(',')
                                portfolios_to_import[name] = {
                                    'resources': [],
                                    'disease': disease.strip(),
                                    'location': location.strip(),
                                    'year': year.strip(),
                                }
                            else:
                                location = details
                                portfolios_to_import[name] = {
                                    'resources': [],
                                    'disease': disease.strip(),
                                    'location': location.strip(),
                                }
                        else:
                            disease = name
                            if not name in portfolios_to_import:
                                portfolios_to_import[name] = {
                                    'resources': [],
                                    'disease': disease.strip()
                                }
                    if '=' in values[1]:
                        promedId = values[1].split('=')[1]
                        portfolios_to_import[name]['resources'].append(promedId)


    db = pymongo.Connection('localhost', int(args.port))[args.db]
    portfolios = db.portfolios

    print portfolios_to_import
    for name, info in portfolios_to_import.iteritems():
        imported_resources = []
        for resource in info['resources']:
            try:
                import_promed(db, resource)
                imported_resources.append(resource)
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
