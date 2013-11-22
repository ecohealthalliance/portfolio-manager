results = () =>
    @portfolioManager.collections.Results

getResult = (promedId) =>
    results().findOne({promedId: promedId})

getTagColor = (tag) =>
    @portfolioManager.services.tagColor(tag)

tags = () =>
    @portfolioManager.collections.Tags

getAllTags = () =>
    (tag.name for tag in tags().find().fetch())

suggestedTagService = () =>
    @portfolioManager.services.suggestedTagService


Meteor.subscribe('recentTags', () ->
    $('#add-tag-text').typeahead(
        source: getAllTags
    )
)

Meteor.subscribe('popularTags')


Template.tagList.helpers(
    isResultSelected: () ->
        Session.get('selectedResult')
    
    tags: () ->
        promedId = Session.get('selectedResult')
        result = getResult(promedId)
        result?.tags

    color: () ->
        getTagColor(this)

    suggestedTags: () ->
        selectedResult = getResult(Session.get('selectedResult'))

        linkedTags = suggestedTagService().getLinkedTags(selectedResult)
        recentTags = suggestedTagService().getRecentTags(selectedResult)
        popularTags = suggestedTagService().getPopularTags(selectedResult)
        wordTags = suggestedTagService().getWordTags(selectedResult)

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
    if not tags().findOne({name: tag})
        tags().insert({name: tag, category: 'user-added'})
    tagId = tags().findOne({name: tag})._id
    promedId = Session.get('selectedResult')
    result = getResult(promedId)
    if not _.include(result.tags, tag)
        results().update({'_id': result._id}, {'$push': {'tags': tag}})
        tags().update({_id: tagId}, {'$set': {lastUsedDate: new Date()}, '$inc': {count: 1}})

removeTag = (tag) ->
    promedId = Session.get('selectedResult')
    result = getResult(promedId)
    results().update({'_id': result._id}, {'$pull': {'tags': tag}})
    tagId = tags().findOne({name: tag})._id
    tags().update({_id: tagId}, {'$inc': {'count': -1}})

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
        source: getAllTags
    )