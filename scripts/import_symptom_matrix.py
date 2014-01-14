import argparse
import pymongo
import contextlib
from urllib import urlopen

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-port', help='mongodb port', default=27017)
    parser.add_argument('-db', help='mongodb db', default='meteor')
    args = parser.parse_args()

    db = pymongo.Connection('localhost', int(args.port))[args.db]

    MATRIX_URL = "https://ckan-datastore.s3.amazonaws.com/2014-01-14T18:29:26.102Z/matrix-symp-dis-v4.csv"

    with contextlib.closing(urlopen(MATRIX_URL)) as raw_csv:
        lines = raw_csv.read().split('\n')
        diseases = lines[0].split('\t')[2:]
        diseaseSymptoms = dict((disease, []) for disease in diseases)
        for line in lines[1:]:
            cells = line.split('\t')
            symptom = cells[0].lower()
            for index in range(0, len(diseases)):
                if (len(cells) > index + 2) and (cells[index + 2] is '1'):
                    diseaseSymptoms[diseases[index]].append(symptom.lower())
        for disease in diseases:
            db.matrix.insert({
                'disease': disease,
                'symptoms': diseaseSymptoms[disease],
            })
