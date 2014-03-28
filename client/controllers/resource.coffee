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

    #Removing in favor of selectedResourceId
    #isResourceSelected: () ->
    #    Session.get('selectedResource')

    selectedResourceId: () ->
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

    annotatedSelectedResource: ()->
        #I'm not sure if this is the most meteorish way to add the annotator.
        #I tried using the template's render event, but the problem is that
        #it only gets called when the view is first created, so
        #it doesn't update when the resource changes.
        _.defer ()->
            if window.annotator?
                window.annotator.destroy()
            window.annotator = new Annotator('#selected-resource')
            window.annotator.addPlugin('Unsupported')
            window.annotator.addPlugin('Filter')
            window.annotator.addPlugin('Store', {
                #The endpoint of the store on your server.
                prefix: '/annotator'
                annotationData: {
                    uri: window.location.href,
                    templateId: Session.get('selectedResource')
                    test: true
                }
                loadFromSearch: {
                    'uri': window.location.href
                }
            })
            #window.annotator.addPlugin('Categories', {
                #cata : 'cata'
                #catb : 'catb'
            #})
        resourceId = Session.get('selectedResource')
        getResource(resourceId)

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

Template.resource.destroyed = () ->
    window.annotator.destroy()
