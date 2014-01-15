resources = () =>
    @portfolioManager.collections.Resources

getResource = (resourceId) =>
    resources().findOne({_id: resourceId})

getTagColor = (tag) =>
    @portfolioManager.services.tagColor(tag)

tags = () =>
    @portfolioManager.collections.Tags

getAllTags = () =>
    (tag.name for tag in tags().find().fetch())

suggestedTagService = () =>
    @portfolioManager.services.suggestedTagService

getTagCategory = (tag) =>
    suggestedTagService().tagCategory(tag)

getHighlightedTags = () =>
    Session.get('highlightedTags') or []

normalize = (tag) ->
    @portfolioManager.services.normalize(tag)

Meteor.subscribe('recentTags', () ->
    $('#add-tag-text').typeahead(
        source: getAllTags
    )
)

Meteor.subscribe('popularTags')


Template.tagList.helpers(
    showTagList: () ->
        Meteor.userId() and Session.get('selectedResource')
    
    tags: () ->
        resourceId = Session.get('selectedResource')
        resource = getResource(resourceId)
        _.filter(_.keys(resource?.tags or {}), (tag) ->
            not resource.tags[tag].removed
        )

    categoryTags: (category) ->
        resourceId = Session.get('selectedResource')
        resource = getResource(resourceId)
        words = normalize(resource?.content or '').split(' ') or []
        bigrams = (words[i] + ' ' + words[i + 1] for i in [0..words.length - 1])
        trigrams = (words[i] + ' ' + words[i + 1] + ' ' + words[i + 2] for i in [0..words.length - 2])
        matches = tags().find({name: {'$in': words.concat(bigrams).concat(trigrams)}, category: category}).fetch()
        matchingTags = _.map(matches, (match) ->
            match.name
        )
        _.difference(_.unique(matchingTags), _.keys(resource?.tags or {}))

    categories: () ->
        _.filter(_.unique(getTagCategory(tag) for tag in getAllTags()), (tagCategory) ->
            tagCategory
        )

    color: () ->
        getTagColor(this)

    highlighted: (tag) ->
        tag in getHighlightedTags()

    suggestedTags: () ->
        selectedResource = getResource(Session.get('selectedResource'))

        linkedTags = suggestedTagService().getLinkedTags(selectedResource)
        recentTags = suggestedTagService().getRecentTags(selectedResource)
        popularTags = suggestedTagService().getPopularTags(selectedResource)
        wordTags = suggestedTagService().getWordTags(selectedResource)

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

addTag = (tag, category) ->
    @portfolioManager.services.tagService.addTag(tag, category)

removeTag = (tag) ->
    @portfolioManager.services.tagService.removeTag(tag)
    
toggleTagHighlight = (tag) ->
    @portfolioManager.services.tagService.toggleTagHighlight(tag)
    if tag in getHighlightedTags()
        scrollToTag = () ->
            tagSelector = ".tag:contains(#{tag})"
            tagElement = $('#selected-resource').find(tagSelector)
            tagElement[0].scrollIntoView(false)
        setTimeout(scrollToTag, 0)
        

Template.tagList.events(
    'click #add-tag-button' : (event) ->
        tag = $('#add-tag-text').val()
        category = $('#add-tag-category').val()
        if normalize(tag).replace(/\s/g, '')
            addTag(tag, category)

    'click .suggested-tag' : (event) ->
        tag = $(event.currentTarget).text()
        toggleTagHighlight(tag)

    'click .tag :not(.remove-tag)' : (event) ->
        tag = $(event.currentTarget).parent().find('.tag-text').text()
        toggleTagHighlight(tag)

    'click .remove-tag': (event) ->
        tag = $(event.currentTarget).parents('.tag').attr('tag')
        removeTag(tag)

    'click .accept-all-auto-tags': (event) ->
        $(event.target).parent().siblings('.auto-tag').each((index, tagElement) ->
            tag = $(tagElement).find('.tag-text').text()
            addTag(tag)
        )

    'click #hide-all-reviewed-tags': (event) ->
        $('.reviewed-tag').each((index, element) ->
            if ($(element).hasClass('highlighted'))
                toggleTagHighlight($(element).attr('tag'))
        )

    'click #show-all-reviewed-tags': (event) ->
        $('.reviewed-tag').each((index, element) ->
            unless ($(element).hasClass('highlighted'))
                toggleTagHighlight($(element).attr('tag'))
        )

    'click #hide-all-candidate-tags': (event) ->
        $('.auto-tag').each((index, element) ->
            if ($(element).hasClass('highlighted'))
                toggleTagHighlight($(element).attr('tag'))
        )

    'click #show-all-candidate-tags': (event) ->
        $('.auto-tag').each((index, element) ->
            unless ($(element).hasClass('highlighted'))
                toggleTagHighlight($(element).attr('tag'))
        )
)

Template.tagList.rendered = () ->
    $('#add-tag-text').typeahead(
        source: getAllTags
    )