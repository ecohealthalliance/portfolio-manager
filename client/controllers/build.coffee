Template.build.events(
    'click #import-promed-button' : (event) ->
        $('#import-form').hide()
        text = $('#import-promed-ids').val()
        portfolioName = $('#import-name').val()
        $('#import-progress-name').text(portfolioName)
        $('#import-done-name').text(portfolioName)
        $('#import-progress').show()
        promedIds = (id.replace(' ', '') for id in text.split(','))
        Meteor.call('import', promedIds, portfolioName, (error, result) ->
            console.log(error.reason) if error
            path = Router.routes['list'].path({'_id': result})
            $('#import-done-link').attr('href', path)
            $('#import-progress').hide()
            $('#import-done').show()
        )

    'click #new-import': (event) ->
    	$('#import-done').hide()
    	$('#import-name').val('')
    	$('#import-promed-ids').val('')
    	$('#import-form').show()
)