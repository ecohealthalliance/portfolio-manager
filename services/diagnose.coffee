@portfolioManager ?= {}
@portfolioManager.services ?= {}

@portfolioManager.services.diagnose = {}

getPortfolios = () ->
    @portfolioManager.collections.Portfolios.find().fetch()

getResource = (promedId) =>
    Resources = @portfolioManager.collections.Resources
    Resources.findOne({promedId: promedId})

suggestedTagService = () =>
    @portfolioManager.services.suggestedTagService

getTagCategory = (tag) =>
    suggestedTagService().tagCategory(tag)

getSymptomsByDisease = () ->
    symptomsByDisease = {}
    for portfolio in getPortfolios()
        tags = []
        for promedId in portfolio.resources
            resource = getResource(promedId)
            if resource?.tags
                tags = _.union(tags, _.keys(resource.tags))
        symptomTags = _.filter(tags, (tag) ->
            getTagCategory(tag) is 'symptom'
        )
        if symptomsByDisease[portfolio.disease]
            symptomTags = _.union(symptomTags, symptomsByDisease[portfolio.disease])
        symptomsByDisease[portfolio.disease] = symptomTags
    symptomsByDisease


@portfolioManager.services.diagnose.fromSymptoms = (symptoms) =>
    matchingSymptomsByDisease = {}
    for disease, diseaseSymptoms of getSymptomsByDisease()
        matches = _.intersection(symptoms, diseaseSymptoms)
        if matches.length > 0
            matchingSymptomsByDisease[disease] = matches

    matchingSymptomsByDisease


@portfolioManager.services.diagnose.fromText = (text) =>
        Meteor.subscribe('reportTags', text or '')
        words = text.split(' ') or []
        groupedWords = []
        i = 0
        while (i += 1) < words.length
            if 'symptom' is getTagCategory(words[i] + ' ' + words[i + 1] + ' ' + words[i + 2])
                groupedWords.push(words[i] + ' ' + words[i + 1] + ' ' + words[i + 2])
                i += 2
            else if 'symptom' is getTagCategory(words[i] + ' ' + words[i + 1])
                groupedWords.push(words[i] + ' ' + words[i + 1])
                i += 1
            else if 'symptom' is getTagCategory(words[i])
                groupedWords.push(words[i])
        @portfolioManager.services.diagnose.fromSymptoms(groupedWords)

