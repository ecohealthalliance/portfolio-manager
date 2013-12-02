@portfolioManager ?= {}
@portfolioManager.services ?= {}

resources = () =>
    @portfolioManager.collections.Resources

getResource = (promedId) =>
    resources().findOne({promedId: promedId})
    
tags = () =>
    @portfolioManager.collections.Tags

@portfolioManager.services.tagService = {
    addTag: (tag) ->
        if not tags().findOne({name: tag})
            tags().insert({name: tag, category: 'user-added'})
        tagId = tags().findOne({name: tag})._id
        promedId = Session.get('selectedResource')
        resource = getResource(promedId)
        if not _.include(resource.tags, tag)
            resources().update({'_id': resource._id}, {'$push': {'tags': tag}})
            tags().update({_id: tagId}, {'$set': {lastUsedDate: new Date()}, '$inc': {count: 1}})

    removeTag: (tag) ->
        promedId = Session.get('selectedResource')
        resource = getResource(promedId)
        resources().update({'_id': resource._id}, {'$pull': {'tags': tag}})
        tagId = tags().findOne({name: tag})._id
        tags().update({_id: tagId}, {'$inc': {'count': -1}})

}