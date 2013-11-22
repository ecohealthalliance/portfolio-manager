Meteor.subscribe('results')

getResults = (query, options) =>
    Results = @portfolioManager.collections.Results
    Results.find(query, options)

Template.resultsList.helpers(
    results: () ->
        query = Session.get('query')
        if query
            getResults({'tags': query})
        else
            getResults({}, {limit: 50})
)

Template.resultsList.events(
    'click .result-list-item' : (event) ->
        promedId = $(event.currentTarget).attr('promed-id')
        Session.set('selectedResult', promedId)
)

Template.resultListItem.helpers(
    selectedClass: () ->
        if @promedId is Session.get('selectedResult') then " selected" else ""
)