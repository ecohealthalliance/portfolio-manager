import argparse
import pymongo


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
        promedResources = portfolio.get('resources')
        resourceIds = []
        for promedId in promedResources:
            resource = resources.find_one({'promedId': promedId})
            if resource:
                resourceId = resource.get('_id')
                resourceIds.append(resourceId)
        if len(resourceIds) is len(promedResources):
            portfolios.update({'_id': portfolioId}, {'$set': {'resources': resourceIds}})

    for resource in resources.find():
        resourceId = resource.get('_id')
        resources.update({'_id': resourceId}, {'$set': {'source': 'promed'}})
