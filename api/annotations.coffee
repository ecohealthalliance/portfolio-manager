# This is an implementation of annotator API documented here:
# http://docs.annotatorjs.org/en/latest/storage.html#core-storage-api

# TODOS:
# The search API is not implemented (so all the annotations are read on every page load).
# I have not implemented the auth API.
# The "see other" repsonses might require work arounds for older browsers.

# Notes:
# I have some doubts that Meteor is a good platform for building APIs,
# many of the features I'm using are undocumented and come from the underlying
# node.js code.
# There is a sample implementation of the API written in Python that uses
# an elastic search backend that would be worth considering using instead.

Router.map () ->
    @route('annotator', {
        where: 'server'
        action: () ->
            ##Debug code for printing circular requests objects
            ##cache = []
            ##@response.write(JSON.stringify(@request, (key, value) ->
            ##    if (typeof value == 'object' && value != null)
            ##        if (cache.indexOf(value) != -1)
            ##            #Circular reference found, discard key
            ##            return
            ##        #Store value in our collection
            ##        cache.push(value)
            ##    return value
            ##, 2))
            @response.setHeader('Content-Type', 'application/json')
            @response.write(JSON.stringify({
                name : "Annotator Store API (Meteor)",
                version : '0.0.0'
            }))
    })
    @route('annotator/annotations', {
        path: 'annotator/annotations'
        where: 'server'
        action: () ->
            Annotations = portfolioManager.collections.Annotations;
            switch @request.method
                when "GET"
                    #Return all the annotations
                    @response.setHeader('Content-Type', 'application/json')
                    rows = Annotations.find().map((v)->
                        v.id = v._id
                        return v
                    )
                    @response.write(JSON.stringify(rows))
                when "POST"
                    #Add the annotation to the database
                    @response.writeHead(303, "SEE OTHER", {
                        Location : Meteor.absoluteUrl(
                            "annotator/annotations/" +
                            Annotations.insert(@request.body)
                        )
                    })
    })
    
    @route('annotator/annotations/', {
        path: 'annotator/annotations/:id'
        where: 'server'
        action: () ->
            Annotations = portfolioManager.collections.Annotations;
            switch @request.method
                when "GET"
                    #Get an individual annotation
                    @response.setHeader('Content-Type', 'application/json')
                    annotationObj = Annotations.findOne({
                        _id : @params.id
                    })
                    annotationObj.id = @params.id;
                    @response.write(JSON.stringify(annotationObj))
                when "PUT"
                    Annotations.upsert({
                        _id : @params.id
                    }, @request.body)
                    @response.writeHead(303, "SEE OTHER", {
                        Location : Meteor.absoluteUrl(
                            "annotator/annotations/" +
                            @params.id
                        )
                    })
                when "DELETE"
                    Annotations.remove({
                        _id : @params.id
                    })
                    @response.writeHead(204, "NO CONTENT", {})
                    
    })
    
##    @route('annotator/search', {
##        path: 'annotator/search'
##        where: 'server'
##        action: () ->
##            Annotations = portfolioManager.collections.Annotations;
##            #Return all the annotations
##            @response.setHeader('Content-Type', 'application/json')
##            rows = Annotations.find().map((v)->
##                v.id = v._id
##                return v
##            )
##            @response.write(JSON.stringify({
##                total : rows.length,
##                rows : rows
##            }))
##                    
##    })
