getResources = (query, options) =>
    Resources = @portfolioManager.collections.Resources
    Resources.find(query, options)

getResource = (promedId) =>
    Resources = @portfolioManager.collections.Resources
    Resources.findOne({promedId: promedId})

getPortfolio = (portfolioId) =>
    Portfolios = @portfolioManager.collections.Portfolios
    Portfolios.findOne({_id: portfolioId})

Router.map () ->
   @route('portfolio', {
        path: '/portfolio/:_id/:resourceId?'
        before: () ->
            $('#diagnosis-results').empty()
            Session.set('selectedResource', @params.resourceId)
            Session.set('selectedPortfolio', @params._id)
        waitOn: () ->
            subscriptions = [Meteor.subscribe('resources')]
            if @params.resourceId
                resource = getResource(@params.resourceId)
                subscriptions.push Meteor.subscribe('reportTags', resource?.content or '')
            subscriptions
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
        portfolioId = Session.get('selectedPortfolio')
        if portfolioId
            portfolio = getPortfolio(portfolioId)
            resourceIds = portfolio.resources
            query = {promedId: {'$in': resourceIds}}
            getResources(query)
)

Template.resourcesList.events(
    'click .resource-list-item' : (event) ->
        promedId = $(event.currentTarget).attr('promed-id')
        $('#selected-resource').parent().scrollTop(0)
        Router.go('portfolio', {_id: Session.get('selectedPortfolio'), resourceId: promedId})
)

Template.resourceListItem.helpers(
    selectedClass: () ->
        if @promedId is Session.get('selectedResource') then " selected" else ""
)