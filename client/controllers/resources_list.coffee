Meteor.subscribe('resources')

getResources = (query, options) =>
    Resources = @portfolioManager.collections.Resources
    Resources.find(query, options)

getPortfolio = (portfolioId) =>
    Portfolios = @portfolioManager.collections.Portfolios
    Portfolios.findOne({_id: portfolioId})

yieldTemplates =
    'portfolio-icons-nav': {to: 'icons-nav'}
    'portfolio-table-nav': {to: 'table-nav'}

Router.map () ->
   @route('list', {
        path: '/list/:_id/:resourceId?'
        yieldTemplates: yieldTemplates
        before: () ->
            Session.set('selectedResource', @params.resourceId)
            Session.set('selectedPortfolio', @params._id)
        after: () ->
            setSize = () ->
                navbarHeight = $('.navbar').height()
                mainHeight = window.innerHeight - navbarHeight
                $('.wrapper').height(mainHeight)
                portfolioInfoHeight = $('#portfolio-info').height()
                resourcesListHeight = mainHeight - portfolioInfoHeight
                $('#resources-list-wrapper').height(resourcesListHeight)
            $(window).resize(setSize)
            setTimeout(setSize, 0)
    }) 

Template.resourcesList.helpers(
    resources: () ->
        query = Session.get('query')
        if query
            getResources({'tags': query})
        else
            portfolioId = Session.get('selectedPortfolio')
            if portfolioId
                portfolio = getPortfolio(portfolioId)
                resourceIds = portfolio.resources
                query = {promedId: {'$in': resourceIds}}
                getResources(query)
            else
                getResources({}, {limit: 50})
)

Template.resourcesList.events(
    'click .resource-list-item' : (event) ->
        promedId = $(event.currentTarget).attr('promed-id')
        $('#selected-resource').parent().scrollTop(0)
        Router.go('list', {_id: Session.get('selectedPortfolio'), resourceId: promedId})
)

Template.resourceListItem.helpers(
    selectedClass: () ->
        if @promedId is Session.get('selectedResource') then " selected" else ""
)