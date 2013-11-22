@portfolioManager ?= {}
@portfolioManager.services ?= {}

tags = () =>
    @portfolioManager.collections.Tags

resources = () =>
    @portfolioManager.collections.Resources

getTagCategory = (tag) =>
    tags().findOne({name: tag})?.category

@portfolioManager.services.suggestedTagService =

    getLinkedTags: (selectedResource) =>
        linkedTags = []
        linkedReports = selectedResource?.linkedReports or []
        for reportId in linkedReports
            resource = resources().findOne({promedId: reportId})
            if resource?.tags
                linkedTags = linkedTags.concat(resource.tags)
        _.unique(_.difference(linkedTags, selectedResource?.tags))

    getRecentTags: (selectedResource) =>
        recentTags = (tag.name for tag in tags().find({}, {sort: {lastUsedDate: -1}, limit: 10}).fetch())
        _.unique(_.difference(recentTags, selectedResource?.tags))

    getPopularTags: (selectedResource) =>
        popularTags = (tag.name for tag in tags().find({}, {sort: {count: -1}, limit: 10}).fetch())
        _.unique(_.difference(popularTags, selectedResource?.tags))

    getWordTags: (selectedResource) =>
        words = selectedResource?.content?.split(/\s/)

        words = _.map(words, (word) -> word.toLowerCase().replace(/[\.,\/#!$%\^&\*;:{}=`~()]/g,""))
        words = _.filter(words, (word) ->
            word.length > 4
        )
        wordCounts = _.countBy(words, (word) -> word)
        wordTags = _.sortBy(_.keys(wordCounts), (word) ->
            -wordCounts[word]
        )
        _.unique(_.difference(wordTags, selectedResource?.tags))[0...10]

    tagCategory : (word) =>
        normalizedWord = word.toLowerCase().replace(/[\.,\/#!$%\^&\*;:{}=`~()]/g,"")
        getTagCategory(normalizedWord)
