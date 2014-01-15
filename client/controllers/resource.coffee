getPortfolio = (id) =>
    Portfolios = @portfolioManager.collections.Portfolios
    Portfolios.findOne({_id: id})

getResource = (resourceId) =>
    Resources = @portfolioManager.collections.Resources
    Resources.findOne({_id: resourceId})

getReviewedResources = (resourceIds) ->
    Resources = @portfolioManager.collections.Resources
    Resources.find({'_id': {'$in': resourceIds}, 'reviewed': {'$type': 3}}).fetch()

getTagColor = (tag) =>
    @portfolioManager.services.tagColor(tag)

getTagCategory = (tag) =>
    suggestedTagService = @portfolioManager.services.suggestedTagService
    suggestedTagService.tagCategory(tag)

addTag = (tag) ->
    @portfolioManager.services.tagService.addTag(tag)

removeTag = (tag) ->
    @portfolioManager.services.tagService.removeTag(tag)

normalize = (tag) ->
    @portfolioManager.services.normalize(tag)

getHighlightedTags = () ->
    Session.get('highlightedTags') or []


Template.resource.helpers(
    selectedPortfolio: () ->
        getPortfolio(Session.get('selectedPortfolio'))

    isResourceSelected: () ->
        Session.get('selectedResource')

    highlighted: (tag) ->
        tag.category and normalize(tag.word) in getHighlightedTags()

    selectedResourceWords: () ->
        resourceId = Session.get('selectedResource')
        resource = getResource(resourceId)
        words = resource?.content.split(' ') or []
        highlightedTags = getHighlightedTags()
        groupedWords = []
        i = 0
        while (i += 1) < words.length
            if normalize(words[i] + ' ' + words[i + 1] + ' ' + words[i + 2]) in highlightedTags
                groupedWords.push(words[i] + ' ' + words[i + 1] + ' ' + words[i + 2])
                i += 2
            else if normalize(words[i] + ' ' + words[i + 1]) in highlightedTags
                groupedWords.push(words[i] + ' ' + words[i + 1])
                i += 1
            else
                groupedWords.push(words[i])
        ({word: word, category: getTagCategory(word)} for word in groupedWords)

    color: () ->
        getTagColor(normalize(@word))

    reviewedCount: () ->
        getReviewedResources(@resources).length

    totalCount: () ->
        @resources.length

    progressBarLength: () ->
        (200 * getReviewedResources(@resources).length / @resources.length) + 'px'
)

Template.resource.events(
    'click .tag-container :not(.remove-tag)': (event) ->
        tag = $(event.currentTarget).parent('.tag-container').children('.tag').html()
        addTag(normalize(tag))

    'click .tag-container .remove-tag': (event) ->
        tag = $(event.currentTarget).parents('.tag-container').children('.tag').html()
        removeTag(normalize(tag))
        event.preventDefault()
        false
)
