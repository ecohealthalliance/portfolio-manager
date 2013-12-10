Meteor.subscribe('portfolios')

getPortfolios = () =>
    Portfolios = @portfolioManager.collections.Portfolios
    Portfolios.find()

clearSelections = () ->
    Session.set('selectedResource', null)
    Session.set('selectedPortfolio', null)

yieldTemplates =
    'portfolio-icons-nav': {to: 'icons-nav'}
    'portfolio-table-nav': {to: 'table-nav'}

Router.map () ->
    @route('portfolioIcons', {
        path: '/portfolios/icons'
        before: clearSelections
        yieldTemplates: yieldTemplates
    })

    @route('portfolioTable', {
        path: '/portfolios/table'
        before: clearSelections
        yieldTemplates: yieldTemplates
    })

Template.portfolioIcons.helpers(
    portfolios: () ->
        getPortfolios()
)

Template.portfolioIcon.helpers(
    reportCountUnit: () ->
        if @resources.length is 1 then 'report' else 'reports'
)

Template.portfolioTable.helpers(
    portfolios: () ->
        getPortfolios()
)

Template.portfolioTable.events(
    'click #portfolio-table tr': (event) ->
        portfolioId = $(event.currentTarget).attr('portfolio')
        Router.go('list', {_id: portfolioId})
)