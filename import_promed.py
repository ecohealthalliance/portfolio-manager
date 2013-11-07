import pymongo
import re
from glob import glob

db = pymongo.Connection('localhost', 3002)['meteor']

results = db.results

REPORT_PATH = '/Users/aslagle/src/grits_scripts/data/promed'
files = glob('%s/*.txt' % REPORT_PATH)
label_regex = re.compile('>.*?Archive Number')

for file in files:
	promedId = file.split('/')[-1].split('.')[0]
	with open(file) as f:
		report = f.read()

		match = label_regex.search(report)
        if match:
        	label = match.group(0)[1:-14].strip()
        else:
            label = promedId

        results.insert({
        	'promedId': promedId,
        	'title': label,
        	'content': report,
        })