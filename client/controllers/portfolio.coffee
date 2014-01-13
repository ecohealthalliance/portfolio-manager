Meteor.subscribe('resources')

getResources = (query, options) =>
    Resources = @portfolioManager.collections.Resources
    Resources.find(query, options)

getResource = (resourceId) =>
    Resources = @portfolioManager.collections.Resources
    Resources.findOne({_id: resourceId})

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
            resource = getResource(@params.resourceId)
            resourceTags = _.keys(resource?.tags or {})
            Session.set('highlightedTags', resourceTags)
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
        unload: () ->
            $('.wrapper').removeAttr('style')
    }) 

Template.resourcesList.helpers(
    resources: () ->
        portfolioId = Session.get('selectedPortfolio')
        if portfolioId
            portfolio = getPortfolio(portfolioId)
            resourceIds = portfolio.resources
            query = {_id: {'$in': resourceIds}}
            getResources(query)
)

Template.resourcesList.events(
    'click .resource-list-item' : (event) ->
        resourceId = $(event.currentTarget).attr('resource-id')
        $('#selected-resource').parent().scrollTop(0)
        Router.go('portfolio', {_id: Session.get('selectedPortfolio'), resourceId: resourceId})
)

Template.resourceListItem.helpers(
    selectedClass: () ->
        if @_id is Session.get('selectedResource') then " selected" else ""
)