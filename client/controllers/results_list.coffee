Meteor.subscribe('results')

Template.resultsList.helpers(
    results: () ->
        @portfolioManager.Results.find()
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