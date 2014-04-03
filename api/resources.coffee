Router.map () ->
    @route 'resources',
        where: 'server'
        action: () ->
            resources = portfolioManager.collections.Resources.find().fetch();
            @response.setHeader('Content-Type', 'application/json')
            @response.write(JSON.stringify(resources))
    @route 'resources',
        path: 'resources/:id'
        where: 'server'
        action: () ->
            resource = portfolioManager.collections.Resources.findOne(@params.id);
            @response.setHeader('Content-Type', 'application/json')
            @response.write(JSON.stringify(resource))