Template.result.helpers(
    isResultSelected: () ->
        Session.get('selectedResult')

    selectedResultWords: () ->
        promedId = Session.get('selectedResult')
        result = @portfolioManager.Results.findOne({promedId: promedId})
        words = result?.content.split(' ') or []
        ({word: word, isTag: @portfolioManager.Tags.findOne({tag: word.toLowerCase().replace(/[\.,\/#!$%\^&\*;:{}=`~()]/g,"")})} for word in words)

    color: () ->
    	window.portfolioManager.tagColor(@word.toLowerCase().replace(/[\.,\/#!$%\^&\*;:{}=`~()]/g,""))
)