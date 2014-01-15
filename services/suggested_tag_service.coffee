@portfolioManager ?= {}
@portfolioManager.services ?= {}

tags = () =>
    @portfolioManager.collections.Tags

resources = () =>
    @portfolioManager.collections.Resources

getTagCategory = (tag) =>
    tags().findOne({name: tag})?.category

normalize = (tag) ->
    @portfolioManager.services.normalize(tag)

@portfolioManager.services.suggestedTagService =

    getLinkedTags: (selectedResource) =>
        linkedTags = []
        linkedReports = selectedResource?.linkedReports or []
        for reportId in linkedReports
            resource = resources().findOne({promedId: reportId})
            if resource?.tags
                linkedTags = linkedTags.concat(_.filter(_.keys(resource.tags), (tag) ->
                    not resource.tags[tag].removed
                ))
        _.unique(_.difference(linkedTags, _.keys(selectedResource?.tags or {})))

    getRecentTags: (selectedResource) =>
        recentTags = (tag.name for tag in tags().find({}, {sort: {lastUsedDate: -1}, limit: 10}).fetch())
        _.unique(_.difference(recentTags, _.keys(selectedResource?.tags)))

    getPopularTags: (selectedResource) =>
        popularTags = (tag.name for tag in tags().find({}, {sort: {count: -1}, limit: 10}).fetch())
        _.unique(_.difference(popularTags, _.keys(selectedResource?.tags)))

    getWordTags: (selectedResource) =>
        words = selectedResource?.content?.split(/\s/)

        words = _.map(words, (word) -> normalize(word))
        words = _.filter(words, (word) ->
            word.length > 4
        )
        wordCounts = _.countBy(words, (word) -> word)
        wordTags = _.sortBy(_.keys(wordCounts), (word) ->
            -wordCounts[word]
        )
        _.unique(_.difference(wordTags, _.keys(selectedResource?.tags)))[0...10]

    tagCategory : (word) =>
        getTagCategory(normalize(word))

