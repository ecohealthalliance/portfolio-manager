portfolios = () =>
    @portfolioManager.collections.Portfolios

Template.portfolioMetadata.helpers(
    canEdit:
        Meteor.userId()
)

Template.portfolioMetadata.events(
    'click #add-metadata-button': (event) ->
        selectedPortfolioId = Session.get('selectedPortfolio')
        metadataType = $('#metadata-type').val()
        metadataValue = $('#metadata-value').val()
        update = {}
        update[metadataType] = metadataValue
        portfolios().update({_id: selectedPortfolioId}, {'$set': update})

)