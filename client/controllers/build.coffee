createPortfolio = (name) ->
    Portfolios = @portfolioManager.collections.Portfolios
    Portfolios.insert({
        'name': name
        'createDate': new Date().getTime()
        'resources': []
    })


Template.build.events(
    'click #import-promed-button' : (event) ->
        $('#import-form').hide()
        text = $('#import-promed-ids').val()
        portfolioName = $('#import-name').val()
        $('#import-progress-name').text(portfolioName)
        $('#import-done-name').text(portfolioName)
        $('#import-progress').show()
        promedIds = (id.replace(' ', '') for id in text.split(','))
        portfolioId = createPortfolio(portfolioName)
        Meteor.call('import', promedIds, portfolioId, (error, result) ->
            console.log(error.reason) if error
            path = Router.routes['list'].path({'_id': portfolioId})
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