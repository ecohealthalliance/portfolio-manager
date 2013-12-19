getPortfolio = (id) ->
    Portfolios = @portfolioManager.collections.Portfolios
    Portfolios.findOne({_id: id})

Router.map () ->
    @route('exportPortfolio', {
        path: '/server/portfolio/:_id/export'
        where: 'server'
        action: () ->
            portfolio = getPortfolio(@params._id)
            @response.setHeader('Content-Type', 'application/json')
            @response.write(JSON.stringify(portfolio))
        }
    )