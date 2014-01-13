getResource = (resourceId) =>
    Resources = @portfolioManager.collections.Resources
    Resources.findOne({_id: resourceId})

Template.portfolioTags.helpers(
    tags: () ->
        tags = []
        for resourceId in @resources
            resource = getResource(resourceId)
            if resource?.tags
                resourceTags = _.filter(_.keys(resource.tags), (tag) ->
                    tag and not resource.tags[tag].removed
                )
                tags = _.union(tags, resourceTags)
        tags
)