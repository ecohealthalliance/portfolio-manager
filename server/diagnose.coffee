getPortfolios = () ->
    @portfolioManager.collections.Portfolios.find().fetch()

getResource = (resourceId) =>
    Resources = @portfolioManager.collections.Resources
    Resources.findOne({_id: resourceId})

getMatrix = () =>
    Matrix = @portfolioManager.collections.Matrix
    Matrix.find().fetch()

tags = () =>
    @portfolioManager.collections.Tags

getTagCategory = (tag) =>
    tags().findOne({name: tag})?.category

normalize = (tag) ->
    @portfolioManager.services.normalize(tag)


getSymptomsByReport = () ->
    symptomsByReport = []
    for portfolio in getPortfolios()
        if portfolio.disease
            for resourceId in portfolio.resources
                resource = getResource(resourceId)
                symptomTags = _.filter(_.keys(resource?.tags or {}), (tag) ->
                    getTagCategory(tag) is 'symptom' and not resource.tags[tag].removed
                )
                symptomsByReport.push(
                    disease: portfolio.disease
                    symptoms: symptomTags
                )
    symptomsByReport


getSymptomsByDisease = () ->
    symptomsByDisease = {}
    for report in getSymptomsByReport()
        disease = report.disease
        symptoms = report.symptoms
        if symptomsByDisease[disease]
            symptoms = _.union(symptomsByDisease[disease], symptoms)
        symptomsByDisease[disease] = symptoms

    for row in getMatrix()
        if not symptomsByDisease[row.disease]
            symptomsByDisease[row.disease] = row.symptoms

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


svmFromSymptoms = (symptoms) =>
    try
        response = HTTP.post("http://localhost:5000/diagnose", {data: {
            training_data: getSymptomsByReport()
            test_data: symptoms
        }})
        response.content
    catch error
        console.log "SVM diagnosis server unavailable"
        null


svmFromText = (text) =>
    svmFromSymptoms(getSymptomsFromText(text))


Meteor.methods(
    'diagnose' : (text) ->
        svmDisease = svmFromText(text)
        matrixResults = matrixFromText(text)
        if svmDisease
            {svm: svmDisease, matrix: matrixResults}
        else
            {matrix: matrixResults}

    'diagnoseSymptoms': (symptoms) ->
        svmDisease = svmFromSymptoms(symptoms)
        matrixResults = matrixFromSymptoms(symptoms)
        if svmDisease
            {svm: svmDisease, matrix: matrixResults}
        else
            {matrix: matrixResults}
)
