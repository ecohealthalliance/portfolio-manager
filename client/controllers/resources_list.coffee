Meteor.subscribe('resources')

getResources = (query, options) =>
    Resources = @portfolioManager.collections.Resources
    Resources.find(query, options)

Template.resourcesList.helpers(
    resources: () ->
        query = Session.get('query')
        if query
            getResources({'tags': query})
        else
            getResources({}, {limit: 50})
)

Template.resourcesList.events(
    'click .resource-list-item' : (event) ->
        promedId = $(event.currentTarget).attr('promed-id')
        Session.set('selectedResource', promedId)
)

Template.resourceListItem.helpers(
    selectedClass: () ->
        if @promedId is Session.get('selectedResource') then " selected" else ""
)