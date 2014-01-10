import pymongo
from bson.objectid import ObjectId
import re
import contextlib
import json
import time
from urllib import urlopen, unquote, urlencode

report_id_regex = re.compile('\d{8}\.\d+')
label_regex = re.compile('>.*?Archive Number')
search_id_regex = re.compile('id(p?h?p?h?\d+)')
zoom_lat_regex = re.compile('LatLng\((\d+\.\d+),')
zoom_lon_regex = re.compile('LatLng\(\d+\.\d+,\s(\-?\d+\.\d+)\)')
zoom_level_regex = re.compile('setZoom\((\d+)\)')
long_label_regex = re.compile('Subject\:.*?Archive Number')
html_markup_regex = re.compile('<.*?>', flags=re.MULTILINE)
extra_space_regex = re.compile('\s+', flags=re.MULTILINE)

def import_promed(db, id):
    url = "http://www.promedmail.org/getPost.php?alert_id=%s" % id
    with contextlib.closing(urlopen(url)) as raw_response:
        try:
            text = raw_response.read()
            response = json.loads(raw_response.read())
            content = json.loads(response.content)
            zoomLat = content.zoom_lat
            zoomLon = content.zoom_lon
            zoomLevel = content.zoom_level
            post = content.post

            try:
                post = unquote(post)
            except Exception as e:
                print "Error decoding %s: %s" % (id, e)

            match = label_regex.search(report)
            if match:
                label = match.group(0)[1:-14].strip()
            else:
                label = id

            linked_reports = [report_id for report_id in report_id_regex.findall(report)]

            resources.update({'promedId': id}, {
                'promedId': id,
                'title': label,
                'content': post,
                'linkedReports': linked_reports,
                'zoomLat': zoomLat,
                'zoomLon': zoomLon,
                'zoomLevel': zoomLevel,
            }, upsert=True)
        except Exception as import_error:
            print "Error importing %s, trying alternate: %s" % (id, import_error)
            url = "http://www.promedmail.org/pm.server.php"
            searchParams = {
                'xajax': 'advanced_search',
                'xajaxr': int(time.time()),
                'xajaxargs[]': "<xjxquery><q>archiveid=%s&submit=search</q></xjxquery>" % id,
            }
            with contextlib.closing(urlopen(url, urlencode(searchParams))) as search_response:
                searchResponseText = search_response.read()
                searchIdMatch = search_id_regex.search(searchResponseText)
                searchId = id
                if not searchIdMatch:
                    print searchResponseText
                else:
                    searchId = searchIdMatch.group(1)
                previewParams = {
                    'xajax': 'preview',
                    'xajaxr': int(time.time()),
                    'xajaxargs[]': searchId
                }
                with contextlib.closing(urlopen(url, urlencode(previewParams))) as preview_response:
                    content = preview_response.read()
                    zoomLat, zoomLon, zoomLevel = None, None, None
                    zoomLatMatch = zoom_lat_regex.search(content)
                    if zoomLatMatch:
                        zoomLat = zoomLatMatch.group(1)
                    zoomLonMatch = zoom_lon_regex.search(content)
                    if zoomLonMatch:
                        zoomLon = zoomLonMatch.group(1)
                    zoomLevelMatch = zoom_level_regex.search(content)
                    if zoomLevelMatch:
                        zoomLevel = zoomLevelMatch.group(1)
                    content = re.sub(html_markup_regex, ' ', content)
                    content = re.sub(extra_space_regex, ' ', content)
                    label = long_label_regex.search(content).group(0)[9:-15].strip()
                    linked_reports = [report_id for report_id in report_id_regex.findall(content)]

                    db.resources.update({'promedId': id}, {
                        '_id': str(ObjectId()),
                        'promedId': id,
                        'title': label,
                        'content': content,
                        'linkedReports': linked_reports,
                        'zoomLat': zoomLat,
                        'zoomLon': zoomLon,
                        'zoomLevel': zoomLevel,
                    }, upsert=True)










                
