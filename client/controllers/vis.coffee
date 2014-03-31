getResources = (query, options) =>
    Resources = @portfolioManager.collections.Resources
    Resources.find(query, options).fetch()

getResource = (resourceId) =>
    Resources = @portfolioManager.collections.Resources
    Resources.findOne({_id: resourceId})

getPortfolio = (portfolioId) =>
    Portfolios = @portfolioManager.collections.Portfolios
    Portfolios.findOne({_id: portfolioId})

Template.vis.helpers
    reportsList: () ->
        selectedResource = getResource(Session.get('selectedResource'))
        if selectedResource
            selectedResource.promedId
        else
            selectedPortfolio = getPortfolio(Session.get('selectedPortfolio'))
            if selectedPortfolio
                resources = getResources({'_id': {'$in': selectedPortfolio.resources}})
                promedIds = (resource.promedId for resource in resources)
                promedIds.join(',')