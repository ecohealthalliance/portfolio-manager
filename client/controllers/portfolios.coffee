Meteor.subscribe('portfolios')

getPortfolios = () =>
    @portfolioManager.collections.Portfolios

clearSelections = () ->
    Session.set('selectedResource', null)
    Session.set('selectedPortfolio', null)

Router.map () ->
    @route('portfolioIcons', {
        path: '/portfolios/icons'
        before: clearSelections
        waitOn:
            Meteor.subscribe('portfolios')
    })

    @route('portfolioTable', {
        path: '/portfolios/table'
        before: clearSelections
        waitOn:
            Meteor.subscribe('portfolios')
    })

Template.portfolioIcons.helpers(
    portfolios: () ->
        getPortfolios().find()

    loggedIn: () ->
        Meteor.userId()
)

Template.portfolioIcon.helpers(
    reportCountUnit: () ->
        if @resources.length is 1 then 'report' else 'reports'
)

Template.portfolioTable.helpers(
    portfolios: () ->
        getPortfolios()

    fields: () ->
        [
            { key: 'name', label: 'Name' }
            { key: 'disease', label: 'Disease' }
            { key: 'location', label: 'Location' }
            { key: 'year', label: 'Year' }
            { 
                key: 'resources'
                label: 'Resources'
                fn: (value) -> value.length
            }
        ]

    attrs: () ->
        portfolio: '_id'
)

Template.portfolioTable.events(
    'click #portfolio-table tbody tr': (event) ->
        portfolioId = $(event.currentTarget).attr('portfolio')
        Router.go('portfolio', {_id: portfolioId})
)