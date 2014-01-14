import argparse
import pymongo
from bson.objectid import ObjectId
import contextlib
from urllib import urlopen
import json
import re
from datetime import datetime
from import_promed import import_promed


report_id_regex = re.compile('\d{8}\.\d+')
new_line_regex = re.compile('\n', flags=re.MULTILINE)
script_regex = re.compile('<script.*?<\/script>', flags=re.MULTILINE)
style_regex = re.compile('<style.*?<\/style>', flags=re.MULTILINE)
html_markup_regex = re.compile('<.*?>', flags=re.MULTILINE)
extra_space_regex = re.compile('\s+', flags=re.MULTILINE)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-port', help="mongodb port", default=27017)
    parser.add_argument('-db', help="mongodb db", default="meteor")
    parser.add_argument('-file', help="json file from healthmap")
    parser.add_argument('-portfolioName', help="name for new portfolio")

    args = parser.parse_args()

    db = pymongo.Connection('localhost', int(args.port))[args.db]
    portfolios = db.portfolios
    resources = db.resources

    imported_resources = []

    with open(args.file) as f:
        data = json.loads(f.read())
        for location in data[0:10]:
            lat = location.get('lat')
            lon = location.get('lng')
            country = location.get('country')

            for result in location.get('alerts')[0:20]:
                feed = result.get('feed')
                disease = result.get('disease')
                title = result.get('summary')
                link = result.get('link')
                descr = result.get('descr')
                date = result.get('date')

                if link:
                    with contextlib.closing(urlopen(link)) as linkResponse:
                        html = linkResponse.read()
                        resourceId = None
                        if 'ProMED' in feed:
                            reportIdMatch = report_id_regex.search(html)
                            if reportIdMatch:
                                reportId = reportIdMatch.group(0)
                                import_promed(db, reportId)
                                resourceId = resources.find_one({'promedId': reportId}).get('_id')
                            else:
                                html = descr
                        elif 'Error 403' in html or 'Sorry, this article is not currently available' in html:
                            html = descr
                        
                        if not resourceId:
                            content = re.sub(new_line_regex, ' ', html)
                            content = re.sub(script_regex, ' ', content)
                            content = re.sub(style_regex, ' ', content)
                            content = re.sub(html_markup_regex, ' ', content)
                            content = re.sub(extra_space_regex, ' ', content)
                            if 'Error 403' in content:
                                content = descr

                            resourceId = resources.insert({
                                '_id': str(ObjectId()),
                                'title': title,
                                'content': content,
                                'zoomLat': lat,
                                'zoomLon': lon,
                                'date': date,
                                'source': 'healthmap',
                            })
                            print "Imported %s" % title
                        imported_resources.append(resourceId)

    portfolios.insert({
        '_id': str(ObjectId()),
        'name': args.portfolioName,
        'resources': imported_resources,
        'createDate': datetime.now(),
    })
