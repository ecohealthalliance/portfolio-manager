getResource = (promedId) =>
    Resources = @portfolioManager.collections.Resources
    Resources.findOne({promedId: promedId})

Template.portfolioTags.helpers(
    tags: () ->
        tags = []
        for promedId in @resources
            resource = getResource(promedId)
            if resource?.tags
                tags = _.union(tags, _.keys(resource.tags))
        _.without(tags, undefined)
)