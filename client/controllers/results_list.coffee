Meteor.subscribe('results')

Template.resultsList.helpers(
    results: () ->
    	query = Session.get('query')
    	if query
    		@portfolioManager.Results.find({'tags': query})
    	else
	        @portfolioManager.Results.find({}, {limit: 50})
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