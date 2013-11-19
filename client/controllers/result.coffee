Template.result.helpers(
    isResultSelected: () ->
        Session.get('selectedResult')

    selectedResultWords: () ->
        promedId = Session.get('selectedResult')
        result = @portfolioManager.Results.findOne({promedId: promedId})
        Meteor.subscribe('reportTags', result?.content or '')
        words = result?.content.split(' ') or []
        groupedWords = []
        i = 0
        while (i += 1) < words.length
        	if @portfolioManager.suggestedTagService.tagCategory(words[i] + ' ' + words[i + 1] + ' ' + words[i + 2])
        		groupedWords.push(words[i] + ' ' + words[i + 1] + ' ' + words[i + 2])
        		i += 2
        	else if @portfolioManager.suggestedTagService.tagCategory(words[i] + ' ' + words[i + 1])
        		groupedWords.push(words[i] + ' ' + words[i + 1])
        		i += 1
        	else
        		groupedWords.push(words[i])
        ({word: word, category: @portfolioManager.suggestedTagService.tagCategory(word)} for word in groupedWords)

    color: () ->
    	window.portfolioManager.tagColor(@word.toLowerCase().replace(/[\.,\/#!$%\^&\*;:{}=`~()]/g,""))
)
