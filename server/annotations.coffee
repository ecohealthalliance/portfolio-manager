#Enables everything for debugging
#Annotations = @portfolioManager.collections.Annotations
#Annotations.allow(
#    update: (userId, document, fields, changes) ->
#        userId
#    insert: (userId, document, fields, changes) ->
#        userId
#    remove: (userId, document, fields, changes) ->
#        userId
#)
#
#Meteor.publish('annotations', () ->
#    Annotations.find({})
#)