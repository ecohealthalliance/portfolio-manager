Template.build.events(
    'click #import-promed-button' : (event) ->
        $('#import-promed-button').addClass('disabled')
        text = $('#import-promed-ids').val()
        portfolioName = $('#import-name').val()
        promedIds = (id.replace(' ', '') for id in text.split(','))
        Meteor.call('import', promedIds, portfolioName, (error, result) ->
            console.log(error.reason) if error
            Router.go('list', {'_id': result}) if result
        )
)