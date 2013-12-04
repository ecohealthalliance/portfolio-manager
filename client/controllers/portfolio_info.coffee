getPortfolio = (portfolioId) =>
    Portfolios = @portfolioManager.collections.Portfolios
    Portfolios.findOne({_id: portfolioId})

Template.portfolioInfo.helpers(
    portfolioName: () ->
        getPortfolio(Session.get('selectedPortfolio')).name
)