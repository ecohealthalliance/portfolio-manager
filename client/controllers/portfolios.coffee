Meteor.subscribe('portfolios')

getPortfolios = () =>
    Portfolios = @portfolioManager.collections.Portfolios
    Portfolios.find()

Template.portfolios.helpers(
    portfolios: () ->
        getPortfolios()
)