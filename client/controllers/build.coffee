createPortfolio = (name, disease, location, year) ->
    Portfolios = @portfolioManager.collections.Portfolios
    Portfolios.insert({
        'name': name
        'disease': disease
        'location': location
        'year': year
        'createDate': new Date().getTime()
        'resources': []
    })

Router.map () ->
    @route('build', {
        path: '/build'
    })


Template.build.events(
    'click #import-promed-button' : (event) ->
        $('#import-form').hide()
        text = $('#import-promed-ids').val()
        portfolioName = $('#import-name').val()
        portfolioDisease = $('#import-disease').val()
        portfolioLocation = $('#import-location').val()
        portfolioYear = $('#import-year').val()
        $('#import-progress-name').text(portfolioName)
        $('#import-done-name').text(portfolioName)
        $('#import-progress').show()
        promedIds = (id.replace(' ', '') for id in text.split(','))
        portfolioId = createPortfolio(portfolioName, portfolioDisease, portfolioLocation, portfolioYear)
        Meteor.call('import', promedIds, portfolioId, (error, result) ->
            console.log(error.reason) if error
            path = Router.routes['portfolio'].path({'_id': portfolioId})
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