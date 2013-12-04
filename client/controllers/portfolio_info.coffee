getPortfolio = (portfolioId) =>
    Portfolios = @portfolioManager.collections.Portfolios
    Portfolios.findOne({_id: portfolioId})

Template.portfolioInfo.helpers(
    portfolio: () ->
        getPortfolio(Session.get('selectedPortfolio'))
)