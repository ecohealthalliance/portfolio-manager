getPortfolios = () =>
    Portfolios = @portfolioManager.collections.Portfolios
    Portfolios.find().fetch()

getPortfolio = (id) ->
    Portfolios = @portfolioManager.collections.Portfolios
    Portfolios.findOne({_id: id})

getResources = (resourceIds) ->
    Resources = @portfolioManager.collections.Resources
    Resources.find({'_id': {'$in': resourceIds}, 'source': 'promed'}).fetch()

getResource = (resourceId) =>
    Resources = @portfolioManager.collections.Resources
    Resources.findOne({_id: resourceId})

suggestedTagService = () =>
    @portfolioManager.services.suggestedTagService

getTagCategory = (tag) =>
    suggestedTagService().tagCategory(tag)

greatCircleDistance = (lat1, lon1, lat2, lon2) ->
    # http://www.movable-type.co.uk/scripts/latlong.html
    R = 6371 # km
    toRad = (x) ->
        x * Math.PI / 180

    dLat = toRad(lat2-lat1)
    dLon = toRad(lon2-lon1)
    lat1 = toRad(lat1)
    lat2 = toRad(lat2)
    a = Math.sin(dLat/2) * Math.sin(dLat/2) +
        Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    R * c

createGraph = (resources) ->
    nodes = []
    edges = []
    infoLinks = {}
    for resource in resources
        node = {
            promed_id: resource.promedId
            title: resource.title
            lat: resource.zoomLat
            lon: resource.zoomLon
            symptoms: []
        }
        tags = _.keys(resource.tags or [])
        for tag in tags
            if getTagCategory(tag) is 'symptom'
                node.symptoms.push(tag)
        infoLinks[resource.promedId] = resource.linkedReports
        nodes.push(node)
    for node1 in nodes
        for node2 in nodes
            if node1 isnt node2
                infoLink = (if node2.promed_id in infoLinks[node1.promed_id] then true else false)
                matchingSymptoms = _.intersection(node1.symptoms, node2.symptoms).length
                if node1.lat and node1.lon and node2.lat and node2.lon
                    distance = greatCircleDistance(node1.lat, node1.lon, node2.lat, node2.lon)
                edges.push({
                    source: node1.promed_id
                    target: node2.promed_id
                    info_link: infoLink
                    matching_symptoms: matchingSymptoms
                    geo_distance: distance
                })
    {nodes: nodes, links: edges}

Router.map () ->
    @route('exportPortfolio', {
        path: '/server/portfolio/:_id/export'
        where: 'server'
        action: () ->
            portfolio = getPortfolio(@params._id)
            tags = []
            for resourceId in portfolio.resources
                resource = getResource(resourceId)
                if resource?.tags
                    resourceTags = _.filter(_.keys(resource.tags), (tag) ->
                        tag and not resource.tags[tag].removed
                    )
                    tags = _.union(tags, resourceTags)
                portfolio.tags = tags
            @response.setHeader('Content-Type', 'application/json')
            @response.write(JSON.stringify(portfolio))
        }
    )

    @route('exportGraph', {
        path: '/server/graph/:_id?/export'
        where: 'server'
        action: () ->
            ids = if @params._id then [@params._id] else (portfolio._id for portfolio in getPortfolios())
            portfolios = (getPortfolio(id) for id in ids)
            resources = []
            for portfolio in portfolios
                resources = resources.concat(getResources(portfolio.resources))
            @response.setHeader('Content-Type', 'application/json')
            @response.write(JSON.stringify(createGraph(resources)))
        }
    )