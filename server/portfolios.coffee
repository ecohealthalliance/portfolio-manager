Portfolios = @portfolioManager.collections.Portfolios

Portfolios.allow(
    insert: (userId, document) ->
        console.log "#{new Date()}: user #{userId} inserted #{JSON.stringify(document)}"
        userId

    update: (userId, document, fields, changes) ->
      console.log "#{new Date()}: user #{userId} updated #{document._id} with #{JSON.stringify(changes)}"
      userId
    
)

Meteor.publish('portfolios', () ->
    Portfolios.find({}, {sort: {name: 1}})
)