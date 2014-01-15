import argparse
import pymongo
from datetime import datetime


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-port', help='mongodb port', default=27017)
    parser.add_argument('-db', help='mongodb db', default='meteor')
    args = parser.parse_args()

    db = pymongo.Connection('localhost', int(args.port))[args.db]

    portfolios = db.portfolios
    resources = db.resources

    for portfolio in portfolios.find():
        portfolioId = portfolio.get('_id')
        portfolioResources = portfolio.get('resources')
        hasTags = False
        for resourceId in portfolioResources:
            resource = resources.find_one(resourceId)
            if resource.get('tags'):
                hasTags = True
                break

        if hasTags and (portfolio.get('name') != 'MERS'):
            for resourceId in portfolioResources:
                resources.update({'_id': resourceId}, {'$set': {'reviewed': {
                    'date': datetime.now()
                }}})
 