@portfolioManager ?= {}
@portfolioManager.services ?= {}

tags = () =>
    @portfolioManager.collections.Tags

results = () =>
    @portfolioManager.collections.Results

getTagCategory = (tag) =>
    tags().findOne({name: tag})?.category

@portfolioManager.services.suggestedTagService =

    getLinkedTags: (selectedResult) =>
        linkedTags = []
        linkedReports = selectedResult?.linkedReports or []
        for resultId in linkedReports
            result = results().findOne({promedId: resultId})
            if result?.tags
                linkedTags = linkedTags.concat(result.tags)
        _.unique(_.difference(linkedTags, selectedResult?.tags))

    getRecentTags: (selectedResult) =>
        recentTags = (tag.name for tag in tags().find({}, {sort: {lastUsedDate: -1}, limit: 10}).fetch())
        _.unique(_.difference(recentTags, selectedResult?.tags))

    getPopularTags: (selectedResult) =>
        popularTags = (tag.name for tag in tags().find({}, {sort: {count: -1}, limit: 10}).fetch())
        _.unique(_.difference(popularTags, selectedResult?.tags))

    getWordTags: (selectedResult) =>
        words = selectedResult?.content?.split(/\s/)

        words = _.map(words, (word) -> word.toLowerCase().replace(/[\.,\/#!$%\^&\*;:{}=`~()]/g,""))
        words = _.filter(words, (word) ->
            word.length > 4
        )
        wordCounts = _.countBy(words, (word) -> word)
        wordTags = _.sortBy(_.keys(wordCounts), (word) ->
            -wordCounts[word]
        )
        _.unique(_.difference(wordTags, selectedResult?.tags))[0...10]

    tagCategory : (word) =>
        normalizedWord = word.toLowerCase().replace(/[\.,\/#!$%\^&\*;:{}=`~()]/g,"")
        getTagCategory(normalizedWord)
