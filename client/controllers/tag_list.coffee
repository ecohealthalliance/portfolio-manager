getTags = () =>
    (tag.tag for tag in @portfolioManager.Tags.find().fetch())

Meteor.subscribe('tags', () ->
    $('#add-tag-text').typeahead(
        source: getTags
    )
)

Template.tagList.helpers(
    isResultSelected: () ->
        Session.get('selectedResult')
    
    tags: () ->
        promedId = Session.get('selectedResult')
        result = @portfolioManager.Results.findOne({'promedId': promedId})
        result?.tags

    color: () ->
        window.portfolioManager.tagColor(this)

    suggestedTags: () ->
        selectedResult = @portfolioManager.Results.findOne({'promedId': Session.get('selectedResult')})

        linkedTags = @portfolioManager.suggestedTagService.getLinkedTags(selectedResult)
        recentTags = @portfolioManager.suggestedTagService.getRecentTags(selectedResult)
        popularTags = @portfolioManager.suggestedTagService.getPopularTags(selectedResult)
        wordTags = @portfolioManager.suggestedTagService.getWordTags(selectedResult)

        allSuggestions = _.union(linkedTags, recentTags, popularTags, wordTags)
        topSuggestions = _.sortBy(allSuggestions, (tag) ->
            score = 0
            if _.include(linkedTags, tag)
                score += 30 - _.indexOf(linkedTags, tag)
            if _.include(recentTags, tag)
                score += 15 - _.indexOf(recentTags, tag)
            if _.include(popularTags, tag)
                score += 10 - _.indexOf(popularTags, tag)
            if _.include(wordTags, tag)
                score += 20 - _.indexOf(wordTags, tag)
            -score
        )

        {
            top: topSuggestions[0...15]
            linked: linkedTags
            recent: recentTags
            popular: popularTags
            words: wordTags
        }    
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