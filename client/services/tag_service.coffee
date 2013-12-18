@portfolioManager ?= {}
@portfolioManager.services ?= {}

resources = () =>
    @portfolioManager.collections.Resources

getResource = (promedId) =>
    resources().findOne({promedId: promedId})
    
tags = () =>
    @portfolioManager.collections.Tags

@portfolioManager.services.tagService = {
    addTag: (tag, category) ->
        console.log category
        if not tags().findOne({name: tag})
            tags().insert({name: tag, category: category, userId: Meteor.userId()})
        tagId = tags().findOne({name: tag})._id
        promedId = Session.get('selectedResource')
        resource = getResource(promedId)
        if not _.include(resource.reviewers, Meteor.userId())
            resources().update({'_id': resource._id}, {'$push': {'reviewers': Meteor.userId()}})
        if resource.tags?[tag]?.removed or not _.include(_.keys(resource.tags or {}), tag)
            tagPath = "tags.#{tag}"
            tagInfo = {}
            tagInfo[tagPath] =
                addedBy: Meteor.userId()
                dateAdded: new Date()
                removed: false
            resources().update({'_id': resource._id}, {'$set': tagInfo})
            tags().update({_id: tagId}, {'$set': {lastUsedDate: new Date()}, '$inc': {count: 1}})


    removeTag: (tag) ->
        promedId = Session.get('selectedResource')
        resource = getResource(promedId)
        tagPath = "tags.#{tag}"
        tagInfo = {}
        tagInfo[tagPath] =
            removedBy: Meteor.userId()
            dateRemoved: new Date()
            removed: true
        resources().update({'_id': resource._id}, {'$set': tagInfo})
        if tag in _.keys(resource?.tags?)
            tagId = tags().findOne({name: tag})._id
            tags().update({_id: tagId}, {'$inc': {'count': -1}})
  
}