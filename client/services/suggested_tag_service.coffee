@portfolioManager ?= {}

@portfolioManager.suggestedTagService =

    getLinkedTags: (selectedResult) =>
        linkedTags = []
        linkedReports = selectedResult?.linkedReports or []
        for resultId in linkedReports
            result = @portfolioManager.Results.findOne({promedId: resultId})
            if result?.tags
                linkedTags = linkedTags.concat(result.tags)
        _.unique(_.difference(linkedTags, selectedResult?.tags))

    getRecentTags: (selectedResult) =>
        recentTags = (tag.tag for tag in @portfolioManager.Tags.find({}, {sort: {lastUsedDate: -1}, limit: 10}).fetch())
        _.unique(_.difference(recentTags, selectedResult?.tags))

    getPopularTags: (selectedResult) =>
        popularTags = (tag.tag for tag in @portfolioManager.Tags.find({}, {sort: {count: -1}, limit: 10}).fetch())
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
        tag = word.toLowerCase().replace(/[\.,\/#!$%\^&\*;:{}=`~()]/g,"")
        if @portfolioManager.Symptoms.findOne({name: tag})
            return 'symptom'
        if @portfolioManager.Diseases.findOne({name: tag})
            return 'disease'
        if @portfolioManager.Tags.findOne({tag: tag})
            return 'other'
        null
