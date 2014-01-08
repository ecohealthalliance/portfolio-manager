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


@portfolioManager.services.diagnose.fromSymptoms = (symptoms) ->
    matchingSymptomsByDisease = {}
    for disease, diseaseSymptoms of getSymptomsByDisease()
        matches = _.intersection(symptoms, diseaseSymptoms)
        if matches.length > 0
            matchingSymptomsByDisease[disease] = matches

    matchingSymptomsByDisease
