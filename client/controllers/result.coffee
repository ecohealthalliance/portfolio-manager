Template.result.helpers(
    isResultSelected: () ->
        Session.get('selectedResult')

    selectedResult: () ->
        promedId = Session.get('selectedResult')
        @portfolioManager.Results.findOne({promedId: promedId})
)