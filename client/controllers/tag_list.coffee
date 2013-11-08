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

    suggestedFromLinkedReports: () ->
        tags = []
        selectedResult = @portfolioManager.Results.findOne({'promedId': Session.get('selectedResult')})
        linkedReports = selectedResult?.linkedReports or []
        for resultId in linkedReports
            result = @portfolioManager.Results.findOne({promedId: resultId})
            if result?.tags
                tags = tags.concat(result.tags)
        _.unique(_.difference(tags, selectedResult?.tags))

    suggestedFromRecent: () ->
        selectedResult = @portfolioManager.Results.findOne({'promedId': Session.get('selectedResult')})
        tags = (tag.tag for tag in @portfolioManager.Tags.find({}, {sort: {lastUsedDate: -1}, limit: 10}).fetch())
        _.unique(_.difference(tags, selectedResult?.tags))

    suggestedFromPopular: () ->
        selectedResult = @portfolioManager.Results.findOne({'promedId': Session.get('selectedResult')})
        tags = (tag.tag for tag in @portfolioManager.Tags.find({}, {sort: {count: -1}, limit: 10}).fetch())
        _.unique(_.difference(tags, selectedResult?.tags))

    suggestedFromWords: () ->
        selectedResult = @portfolioManager.Results.findOne({'promedId': Session.get('selectedResult')})
        words = selectedResult?.content?.split(/\s/)
        words = _.filter(words, (word) ->
            word.length > 5
        )
        words = _.map(words, (word) -> word.toLowerCase())
        wordCounts = _.countBy(words, (word) -> word)
        tags = _.sortBy(_.keys(wordCounts), (word) ->
            -wordCounts[word]
        )
        _.unique(_.difference(tags, selectedResult?.tags))[0...10]

    
)

addTag = (tag) ->
    if not @portfolioManager.Tags.findOne({tag: tag})
        @portfolioManager.Tags.insert({tag: tag})
    tagId = @portfolioManager.Tags.findOne({tag: tag})._id
    promedId = Session.get('selectedResult')
    result = @portfolioManager.Results.findOne({promedId: promedId})
    if not _.include(result.tags, tag)
        @portfolioManager.Results.update({'_id': result._id}, {'$push': {'tags': tag}})
        @portfolioManager.Tags.update({_id: tagId}, {'$set': {lastUsedDate: new Date()}, '$inc': {count: 1}})

removeTag = (tag) ->
    promedId = Session.get('selectedResult')
    result = @portfolioManager.Results.findOne({promedId: promedId})
    @portfolioManager.Results.update({'_id': result._id}, {'$pull': {'tags': tag}})
    tagId = @portfolioManager.Tags.findOne({tag: tag})._id
    @portfolioManager.Tags.update({_id: tagId}, {'$inc': {'count': -1}})

Template.tagList.events(
    'click #add-tag-button' : (event) ->
        tag = $('#add-tag-text').val()
        addTag(tag)

    'click .suggested-tag' : (event) ->
        tag = $(event.currentTarget).text()
        addTag(tag)

    'click .remove-tag': (event) ->
        tag = $(event.currentTarget).parents('.tag').attr('tag')
        removeTag(tag)
)

Template.tagList.rendered = () ->
    $('#add-tag-text').typeahead(
        source: getTags
    )