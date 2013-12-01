Template.build.events(
    'click #import-promed-button' : (event) ->
        text = $('#import-promed-ids').val()
        portfolioName = $('#import-name').val()
        promedIds = (id.replace(' ', '') for id in text.split(','))
        Meteor.call('import', promedIds, portfolioName, (error) ->
            console.log(error.reason) if error
        )
)