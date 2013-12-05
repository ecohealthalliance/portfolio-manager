import contextlib
from urllib import urlopen

def import_tag_ideas(db):
    tags = db.tags
    
    CKAN_URL = "https://ckan-datastore.s3.amazonaws.com/2013-12-05T16:33:55.912Z/tagging-brainstorm-sheet1.csv"

    with contextlib.closing(urlopen(CKAN_URL)) as raw_csv:
        category = ''
        for line in raw_csv.read().split('\n'):
            if line:
                new_category, tag = line.split(',')
                if new_category:
                    category = new_category.lower()
                if tag and not tags.find_one({'name': tag.lower()}):
                    tags.insert({
                        'name': tag.lower(),
                        'category': category,
                    })
