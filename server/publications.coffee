Results = @portfolioManager.Results
Tags = @portfolioManager.Tags
Symptoms = @portfolioManager.Symptoms
Diseases = @portfolioManager.Diseases

Tags.allow(
    insert: (userId, document) ->
      console.log "#{new Date()}: user #{userId} inserted #{JSON.stringify(document)}"
      true

    update: (userId, document, fields, changes) ->
      console.log "#{new Date()}: user #{userId} updated #{document._id} with #{JSON.stringify(changes)}"
      true
)

Results.allow(
    update: (userId, document, fields, changes) ->
      console.log "#{new Date()}: user #{userId} updated #{document._id} with #{JSON.stringify(changes)}"
      true
)

Meteor.publish('results', () ->
    Results.find({}, {sort: {promedId: 1}})
)

Meteor.publish('tags', () ->
    Tags.find()
)

Meteor.publish('symptoms', () ->
  Symptoms.find()
)

Meteor.publish('diseases', () ->
  Diseases.find()
)