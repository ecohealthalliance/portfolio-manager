Resources = @portfolioManager.collections.Resources
Tags = @portfolioManager.collections.Tags

Tags.allow(
    insert: (userId, document) ->
      console.log "#{new Date()}: user #{userId} inserted #{JSON.stringify(document)}"
      true

    update: (userId, document, fields, changes) ->
      console.log "#{new Date()}: user #{userId} updated #{document._id} with #{JSON.stringify(changes)}"
      true
)

Resources.allow(
    update: (userId, document, fields, changes) ->
      console.log "#{new Date()}: user #{userId} updated #{document._id} with #{JSON.stringify(changes)}"
      true
)

Meteor.publish('resources', () ->
    Resources.find({}, {sort: {promedId: 1}})
)

Meteor.publish('recentTags', () ->
    Tags.find({}, {sort: {lastUsedDate: -1}, limit: 10})
)

Meteor.publish('popularTags', () ->
    Tags.find({}, {sort: {count: 1}, limit: 10})
)

Meteor.publish('reportTags', (reportText) ->
    words = (word.toLowerCase().replace(/[\.,\/#!$%\^&\*;:{}=`~()]/g,"") for word in reportText.split(' '))
    bigrams = (words[i] + ' ' + words[i+1] for i in [0..words.length])
    trigrams = (words[i] + ' ' + words[i+1] + ' ' + words[i + 2] for i in [0..words.length - 1])
    Tags.find({name: {'$in': words.concat(bigrams).concat(trigrams)}})
)
