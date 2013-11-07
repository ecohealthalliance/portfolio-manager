getTags = () =>
    (tag.tag for tag in @portfolioManager.Tags.find().fetch())

Meteor.subscribe('tags', () ->
    $('#add-tag-text').typeahead(
        source: getTags
    )
)

COLORS = d3.scale.category20()

Template.tagList.helpers(
    isResultSelected: () ->
        Session.get('selectedResult')
    
    tags: () ->
        promedId = Session.get('selectedResult')
        result = @portfolioManager.Results.findOne({'promedId': promedId})
        result?.tags

    color: () ->
        COLORS(this)
)

addTag = (tag) ->
    if not @portfolioManager.Tags.findOne({tag: tag})
        @portfolioManager.Tags.insert({tag: tag})
    promedId = Session.get('selectedResult')
    resultId = @portfolioManager.Results.findOne({promedId: promedId})._id
    @portfolioManager.Results.update({'_id': resultId}, {'$push': {'tags': tag}})


Template.tagList.events(
    'click #add-tag-button' : (event) ->
        tag = $('#add-tag-text').val()
        addTag(tag)
)

Template.tagList.rendered = () ->
    $('#add-tag-text').typeahead(
        source: getTags
    )