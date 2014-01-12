getResource = (resourceId) =>
    Resources = @portfolioManager.collections.Resources
    Resources.findOne({_id: resourceId})

Template.portfolioTags.helpers(
    tags: () ->
        tags = []
        for resourceId in @resources
            resource = getResource(resourceId)
            if resource?.tags
                tags = _.union(tags, _.keys(resource.tags))
        _.without(tags, undefined)
)