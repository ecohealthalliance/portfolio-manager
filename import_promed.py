import pymongo
import re
from glob import glob

db = pymongo.Connection('localhost', 3002)['meteor']

resources = db.resources

REPORT_PATH = '/Users/aslagle/src/grits_scripts/data/promed'
files = glob('%s/*.txt' % REPORT_PATH)
report_id_regex = re.compile('\d{8}\.\d+')
label_regex = re.compile('>.*?Archive Number')

for file in files:
    promed_id = file.split('/')[-1].split('.')[0]
    with open(file) as f:
        report = f.read()

        match = label_regex.search(report)
        if match:
            label = match.group(0)[1:-14].strip()
        else:
            label = promed_id

        report_ids = [report_id.split('.')[1] for report_id in report_id_regex.findall(report)]

        resources.insert({
            'promedId': promed_id,
            'title': label,
            'content': report,
            'linkedReports': report_ids,
        })