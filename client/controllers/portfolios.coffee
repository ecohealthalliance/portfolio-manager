Meteor.subscribe('portfolios')

getPortfolios = () =>
    Portfolios = @portfolioManager.collections.Portfolios
    Portfolios.find()

Router.map () ->
	@route('portfolios', {
		path: '/portfolios'
		before: () ->
			Session.set('selectedResource', null)
			Session.set('selectedPortfolio', null)
	})

Template.portfolios.helpers(
    portfolios: () ->
        getPortfolios()
)

Template.portfolio.helpers(
    reportCountUnit: () ->
    	if @resources.length is 1 then 'report' else 'reports'
)