import contextlib
from urllib import urlopen
from zipfile import ZipFile
from os import remove
from shutil import rmtree


def import_locations(db):
    tags = db.tags

    GEONAMES_URL = 'http://download.geonames.org/export/dump/allCountries.zip'

    with contextlib.closing(urlopen(GEONAMES_URL)) as geonamesZip:
        with open('temp_geonames.zip', 'wb') as tempZipfile:
            tempZipfile.write(geonamesZip.read())

    with ZipFile('temp_geonames.zip') as geonamesZipfile:
        geonamesZipfile.extractall('temp_geonames_data')

    with open('temp_geonames_data/allCountries.txt') as dataFile:
        for line in dataFile.read().split('\n'):
            name = line.split('\t')[1]
            if not tags.find_one({'name': name.lower()}):
                tags.insert({
                    'name': name.lower(),
                    'category': 'location',
                    'source': 'geonames',
                })

    remove('temp_geonames.zip')
    rmtree('temp_geonames_data')