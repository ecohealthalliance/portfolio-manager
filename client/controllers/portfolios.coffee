Meteor.subscribe('portfolios')

getPortfolios = () =>
    Portfolios = @portfolioManager.collections.Portfolios
    Portfolios.find()

Template.portfolios.helpers(
    portfolios: () ->
        getPortfolios()
)

Template.portfolio.helpers(
    reportCountUnit: () ->
    	if @resources.length is 1 then 'report' else 'reports'
)