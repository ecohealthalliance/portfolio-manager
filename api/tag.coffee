tags = () ->
    @portfolioManager.collections.Tags

Router.map () ->
    @route('tag', {
        path: '/tag'
        where: 'server'
        action: () ->
            text = @request.body.text
            if not text
                @response.writeHead(400)
            else
                words = (word.toLowerCase().replace(/[\.,\/#!$%\^&\*;:{}=`~()]/g,"") for word in text.split(' '))
                bigrams = (words[i] + ' ' + words[i+1] for i in [0..words.length])
                trigrams = (words[i] + ' ' + words[i+1] + ' ' + words[i + 2] for i in [0..words.length - 1])
                tagObjects = tags().find({name: {'$in': words.concat(bigrams).concat(trigrams)}}).fetch()
                tagsWithCategories = {}
                for tag in tagObjects
                    tagsWithCategories[tag.name] = tag.category
                @response.setHeader('Content-Type', 'application/json')
                @response.write(JSON.stringify(tagsWithCategories))
    })