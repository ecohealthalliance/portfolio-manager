Template.result.helpers(
    isResultSelected: () ->
        Session.get('selectedResult')

    selectedResultWords: () ->
        promedId = Session.get('selectedResult')
        result = @portfolioManager.Results.findOne({promedId: promedId})
        words = result?.content.split(' ') or []
        ({word: word, category: @portfolioManager.suggestedTagService.tagCategory(word)} for word in words)

    color: () ->
    	window.portfolioManager.tagColor(@word.toLowerCase().replace(/[\.,\/#!$%\^&\*;:{}=`~()]/g,""))
)