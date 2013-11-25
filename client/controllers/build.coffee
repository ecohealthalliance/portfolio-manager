Template.build.events(
	'click #import-promed-button' : (event) ->
		text = $('#import-promed-ids').val()
		promedIds = (id.replace(' ', '') for id in text.split(','))
		Meteor.call('import', promedIds, (error) ->
			console.log(error.reason) if error
		)
)