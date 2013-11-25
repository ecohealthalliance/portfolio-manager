Resources = @portfolioManager.collections.Resources


Resources.allow(
    update: (userId, document, fields, changes) ->
      console.log "#{new Date()}: user #{userId} updated #{document._id} with #{JSON.stringify(changes)}"
      true
)

Meteor.publish('resources', () ->
    Resources.find({}, {sort: {promedId: 1}})
)

Meteor.methods(
    'import' : (ids) ->
        for id in ids
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
                promedId = id.split('.')[1]
                Resources.upsert({promedId: promedId}, {
                    promedId: promedId
                    title: label
                    content: post
                    linkedReports: linkedReports
                    zoomLat: zoomLat
                    zoomLon: zoomLon
                    zoomLevel: zoomLevel
                })
                console.log "ProMED report #{id} imported"
            catch error
                console.log "Error importing #{id}: #{error}"

)