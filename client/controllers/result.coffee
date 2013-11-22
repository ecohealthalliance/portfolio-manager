getResult = (promedId) =>
    Results = @portfolioManager.collections.Results
    Results.findOne({promedId: promedId})

getTagColor = (tag) =>
    @portfolioManager.services.tagColor(tag)

getTagCategory = (tag) =>
    suggestedTagService = @portfolioManager.services.suggestedTagService
    suggestedTagService.tagCategory(tag)

Template.result.helpers(
    isResultSelected: () ->
        Session.get('selectedResult')

    selectedResultWords: () ->
        promedId = Session.get('selectedResult')
        result = getResult(promedId)
        Meteor.subscribe('reportTags', result?.content or '')
        words = result?.content.split(' ') or []
        groupedWords = []
        i = 0
        while (i += 1) < words.length
            if getTagCategory(words[i] + ' ' + words[i + 1] + ' ' + words[i + 2])
                groupedWords.push(words[i] + ' ' + words[i + 1] + ' ' + words[i + 2])
                i += 2
            else if getTagCategory(words[i] + ' ' + words[i + 1])
                groupedWords.push(words[i] + ' ' + words[i + 1])
                i += 1
            else
                groupedWords.push(words[i])
        ({word: word, category: getTagCategory(word)} for word in groupedWords)

    color: () ->
        getTagColor(@word.toLowerCase().replace(/[\.,\/#!$%\^&\*;:{}=`~()]/g,""))
)
