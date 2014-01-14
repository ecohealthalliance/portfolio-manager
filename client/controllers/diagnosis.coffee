getResource = (resourceId) =>
    Resources = @portfolioManager.collections.Resources
    Resources.findOne({_id: resourceId})

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
            content = (getResource(resourceId)?.content for resourceId in portfolio.resources)
            content = content.join(' ')

        $('#diagnosis-results').html('Diagnosing...')
        Meteor.call('diagnose', content, (error, results) -> 
            if error
                console.log error
                $('#diagnosis-results').html('Error getting diagnosis results')
            else
                rankedDiseases = _.sortBy(_.keys(results.matrix), (result) ->
                    -results.matrix[result].length
                )[0..10]
                isSVM = (disease) ->
                    disease is results.svm
                diseasesWithSymptoms = ({name: disease, symptoms: results.matrix[disease], svm: isSVM(disease)} for disease in rankedDiseases)
                if results.svm and not (results.svm in rankedDiseases[0..10])
                    diseasesWithSymptoms.push {
                        name: results.svm
                        symptoms: []
                        svm: true
                    }
                allSymptoms = (disease.symptoms for disease in diseasesWithSymptoms)
                allSymptoms = _.union(_.flatten(allSymptoms))
                html = Template.diagnosisResults({diseases: diseasesWithSymptoms, allSymptoms: allSymptoms})
                $('#diagnosis-results').html(html)
        )


)