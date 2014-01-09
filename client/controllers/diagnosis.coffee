getResource = (promedId) =>
    Resources = @portfolioManager.collections.Resources
    Resources.findOne({promedId: promedId})

getPortfolio = (portfolioId) =>
    Portfolios = @portfolioManager.collections.Portfolios
    Portfolios.findOne({_id: portfolioId})

getTagColor = (tag) =>
    @portfolioManager.services.tagColor(tag)

Template.diagnosisResults.helpers(
    color: () ->
        getTagColor(this)
)

Template.diagnosis.events(
    "click #diagnose-button": (event) ->
        resource = getResource(Session.get('selectedResource'))
        if resource
            content = resource.content
        else
            portfolio = getPortfolio(Session.get('selectedPortfolio'))
            content = (getResource(promedId)?.content for promedId in portfolio.resources)
            content = content.join(' ')

        $('#diagnosis-results').html('Diagnosing...')
        Meteor.call('diagnoseWithMatrixFromText', content, (error, results) -> 
            if error
                console.log error
                $('#diagnosis-results').html('Error getting diagnosis results')
            else
                rankedDiseases = _.sortBy(_.keys(results), (result) ->
                    -results[result].length
                )
                diseasesWithSymptoms = ({name: disease, symptoms: results[disease]} for disease in rankedDiseases)
                allSymptoms = (disease.symptoms for disease in diseasesWithSymptoms)
                allSymptoms = _.union(_.flatten(allSymptoms))
                html = Template.diagnosisResults({diseases: diseasesWithSymptoms, allSymptoms: allSymptoms})
                $('#diagnosis-results').html(html)
        )


)