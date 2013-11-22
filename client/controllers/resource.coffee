getResource = (promedId) =>
    Resources = @portfolioManager.collections.Resources
    Resources.findOne({promedId: promedId})

getTagColor = (tag) =>
    @portfolioManager.services.tagColor(tag)

getTagCategory = (tag) =>
    suggestedTagService = @portfolioManager.services.suggestedTagService
    suggestedTagService.tagCategory(tag)

Template.resource.helpers(
    isResourceSelected: () ->
        Session.get('selectedResource')

    selectedResourceWords: () ->
        promedId = Session.get('selectedResource')
        resource = getResource(promedId)
        Meteor.subscribe('reportTags', resource?.content or '')
        words = resource?.content.split(' ') or []
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
