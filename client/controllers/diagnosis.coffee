getResource = (promedId) =>
    Resources = @portfolioManager.collections.Resources
    Resources.findOne({promedId: promedId})

getPossibleDiagnoses = (content) ->
    @portfolioManager.services.diagnose.fromText(content)

getTagColor = (tag) =>
    @portfolioManager.services.tagColor(tag)

Template.diagnosisResults.helpers(
    color: () ->
        getTagColor(this)
)

Template.diagnosis.events(
    "click #diagnose-button": (event) ->
        resource = getResource(Session.get('selectedResource'))
        results = []
        if resource
            results = getPossibleDiagnoses(resource.content)
        rankedDiseases = _.sortBy(_.keys(results), (result) ->
            -results[result].length
        )
        diseasesWithSymptoms = ({name: disease, symptoms: results[disease]} for disease in rankedDiseases)
        allSymptoms = (disease.symptoms for disease in diseasesWithSymptoms)
        allSymptoms = _.union(_.flatten(allSymptoms))
        html = Template.diagnosisResults({diseases: diseasesWithSymptoms, allSymptoms: allSymptoms})
        $('#diagnosis-results').html(html)


)