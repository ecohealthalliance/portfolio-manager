getPortfolios = () ->
    @portfolioManager.collections.Portfolios.find().fetch()

getResource = (promedId) =>
    Resources = @portfolioManager.collections.Resources
    Resources.findOne({promedId: promedId})

tags = () =>
    @portfolioManager.collections.Tags

getTagCategory = (tag) =>
    tags().findOne({name: tag})?.category

normalize = (tag) ->
    @portfolioManager.services.normalize(tag)

getSymptomsByDisease = () ->
    symptomsByDisease = {}
    for portfolio in getPortfolios()
        portfolioTags = []
        for promedId in portfolio.resources
            resource = getResource(promedId)
            if resource?.tags
                portfolioTags = _.union(portfolioTags, _.keys(resource.tags))
        symptomTags = _.filter(portfolioTags, (tag) ->
            getTagCategory(tag) is 'symptom'
        )
        if symptomsByDisease[portfolio.disease]
            symptomTags = _.union(symptomTags, symptomsByDisease[portfolio.disease])
        symptomsByDisease[portfolio.disease] = symptomTags
    symptomsByDisease

getSymptomsFromText = (text) ->
    words = normalize(text).split(' ') or []
    bigrams = (words[i] + ' ' + words[i + 1] for i in [0..words.length - 1])
    trigrams = (words[i] + ' ' + words[i + 1] + ' ' + words[i + 2] for i in [0..words.length - 2])
    matches = tags().find({name: {'$in': words.concat(bigrams).concat(trigrams)}, category: 'symptom'}).fetch()
    _.map(matches, (match) ->
        match.name
    )


matrixFromSymptoms = (symptoms) =>
    matchingSymptomsByDisease = {}
    for disease, diseaseSymptoms of getSymptomsByDisease()
        matches = _.intersection(symptoms, diseaseSymptoms)
        if matches.length > 0
            matchingSymptomsByDisease[disease] = matches
    matchingSymptomsByDisease


matrixFromText = (text) =>
    matrixFromSymptoms(getSymptomsFromText(text))


Meteor.methods(
    'diagnoseWithMatrixFromSymptoms' : (symptoms) ->
        matrixFromSymptoms(symptoms)

    'diagnoseWithMatrixFromText' : (text) ->
        matrixFromText(text)
)
