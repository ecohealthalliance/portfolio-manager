resources = () =>
    @portfolioManager.collections.Resources

getResource = (promedId) =>
    resources().findOne({promedId: promedId})

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

normalize = (tag) ->
    @portfolioManager.services.normalize(tag)

Meteor.subscribe('recentTags', () ->
    $('#add-tag-text').typeahead(
        source: getAllTags
    )
)

Meteor.subscribe('popularTags')


Template.tagList.helpers(
    isResourceSelected: () ->
        Session.get('selectedResource')
    
    tags: () ->
        promedId = Session.get('selectedResource')
        resource = getResource(promedId)
        resource?.tags

    symptomTags: () ->
        promedId = Session.get('selectedResource')
        resource = getResource(promedId)
        Meteor.subscribe('reportTags', resource?.content or '')
        words = resource?.content.split(' ') or []
        groupedWords = []
        i = 0
        while (i += 1) < words.length
            threeWordCategory = getTagCategory(words[i] + ' ' + words[i + 1] + ' ' + words[i + 2])
            if threeWordCategory
                if threeWordCategory is 'symptom'
                    groupedWords.push(normalize(words[i] + ' ' + words[i + 1] + ' ' + words[i + 2]))
                i += 2
            else 
                twoWordCategory = getTagCategory(words[i] + ' ' + words[i + 1])
                if twoWordCategory
                    if twoWordCategory is 'symptom'
                        groupedWords.push(normalize(words[i] + ' ' + words[i + 1]))
                    i += 1
                else if getTagCategory(words[i]) is 'symptom'
                    groupedWords.push(normalize(words[i]))
        _.difference(_.unique(groupedWords), resource?.removedTags)


    color: () ->
        getTagColor(this)

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

addTag = (tag) ->
    @portfolioManager.services.tagService.addTag(tag)

removeTag = (tag) ->
    @portfolioManager.services.tagService.removeTag(tag)
    
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