Resources = @portfolioManager.collections.Resources
Portfolios = @portfolioManager.collections.Portfolios

Resources.allow(
    update: (userId, document, fields, changes) ->
      console.log "#{new Date()}: user #{userId} updated #{document._id} with #{JSON.stringify(changes)}"
      userId
)

Meteor.publish('resources', () ->
    Resources.find({}, {sort: {promedId: 1}})
)

Meteor.methods(
    'import' : (promedIds, portfolioId) ->
        importedIds = []
        for id in promedIds
            url = "http://www.promedmail.org/getPost.php?alert_id=#{id}"
            try
                response = HTTP.get(url)
                content = JSON.parse(response.content)
                zoomLat = content.zoom_lat
                zoomLon = content.zoom_lon
                zoomLevel = content.zoom_level
                post = content.post
                try
                    post = decodeURI(post)
                catch error
                    console.log "Error decoding #{id}: #{error}"

                post = post.replace(/<.*?>/g, '')
                label = />.*?Archive Number/.exec(post)[0][2...-15]
                linkedReports = (reportId.split('.')[1] for  reportId in post.match(/\d{8}\.\d+/g))
                Resources.upsert({promedId: id}, {
                    promedId: id
                    title: label
                    content: post
                    linkedReports: linkedReports
                    zoomLat: zoomLat
                    zoomLon: zoomLon
                    zoomLevel: zoomLevel
                })
                resourceId = Resources.findOne({promedId: id})._id
                console.log "ProMED report #{id} imported"
                importedIds.push(resourceId)
            catch error
                console.log "Error importing #{id}: #{error}, trying alternate"
                url = "http://www.promedmail.org/pm.server.php"
                searchParams = {
                    xajax: 'advanced_search'
                    xajaxr: new Date().getTime()
                    'xajaxargs[]': "<xjxquery><q>archiveid=#{id}&submit=search</q></xjxquery>"
                }
                try
                    searchResponse = HTTP.post(url, {params: searchParams})
                    searchId = /id(phph\d+)\"/.exec(searchResponse.content)[1]
                    previewParams = {
                        xajax: 'preview'
                        xajaxr: new Date().getTime()
                        'xajaxargs[]': searchId
                    }
                    previewResponse = HTTP.post(url, {params: previewParams})
                    content = previewResponse.content
                    zoomLat = /LatLng\((\d+\.\d+),/.exec(content)?[1]
                    zoomLon = /LatLng\(\d+\.\d+,\s(\d+\.\d+)\)/.exec(content)?[1]
                    zoomLevel = /setZoom\((\d+)\)/.exec(content)?[1]
                    content = content.replace(/<.*?>/g, '')
                    label = /Subject\:.*?Archive Number/.exec(content)[0][9...-15]
                    linkedReports = (reportId.split('.')[1] for  reportId in content.match(/\d{8}\.\d+/g))
                    Resources.upsert({promedId: id}, {
                        promedId: id
                        title: label
                        content: content
                        linkedReports: linkedReports
                        zoomLat: zoomLat
                        zoomLon: zoomLon
                        zoomLevel: zoomLevel
                    })
                    resourceId = Resources.findOne({promedId: id})._id
                    console.log "ProMED report #{id} imported"
                    importedIds.push(resourceId)
                catch error2
                    console.log "Error importing from alternate url: #{error2}"
        for importedId in importedIds
            Portfolios.update({'_id': portfolioId}, {
                '$push': {resources: importedId}
            })
)