Meteor.subscribe('portfolios')

getPortfolios = () =>
    Portfolios = @portfolioManager.collections.Portfolios
    Portfolios.find()

Router.map () ->
	@route('portfolioIcons', {
		path: '/portfolios/icons'
		before: () ->
			Session.set('selectedResource', null)
			Session.set('selectedPortfolio', null)
	})

Template.portfolioIcons.helpers(
    portfolios: () ->
        getPortfolios()
)

Template.portfolioIcon.helpers(
    reportCountUnit: () ->
    	if @resources.length is 1 then 'report' else 'reports'
)