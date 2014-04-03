# This is an implementation of annotator API documented here:
# http://docs.annotatorjs.org/en/latest/storage.html#core-storage-api

# TODOS:
# The search API is not fully implemented.
# I have not implemented the auth API.
# The "see other" repsonses might require work arounds for older browsers.

# Notes:
# Many of the features I'm using are not mentioned in the meteor documentaiton
# and come from the underlying node.js code.
# There are a number of other backend implementations for the annotation plug-in
# mentioned in its github wiki.
# They might be able to replace this one in a future release.

Router.map () ->
    @route('annotator', {
        where: 'server'
        action: () ->
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
            AnnotationsLog = portfolioManager.collections.AnnotationsLog;
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
                    id = Annotations.insert(@request.body)
                    AnnotationsLog.insert
                        type : 'create'
                        data : @request.body
                        id : id
                    
                    #Add the annotation to the database
                    @response.writeHead(303, "SEE OTHER", {
                        Location : Meteor.absoluteUrl(
                            "annotator/annotations/" + id
                        )
                    })
    })
    
    @route('annotator/annotations/', {
        path: 'annotator/annotations/:id'
        where: 'server'
        action: () ->
            Annotations = portfolioManager.collections.Annotations;
            AnnotationsLog = portfolioManager.collections.AnnotationsLog;
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
                    AnnotationsLog.insert
                        type : 'update'
                        data : @request.body
                        id : @params.id
                    
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
                    AnnotationsLog.insert
                        type : 'remove'
                        id : @params.id
                    
                    Annotations.remove({
                        _id : @params.id
                    })
                    @response.writeHead(204, "NO CONTENT", {})
    })
    
    @route('annotator/search', {
        path: 'annotator/search'
        where: 'server'
        action: () ->
            Annotations = portfolioManager.collections.Annotations;
            #Return all the annotations
            @response.setHeader('Content-Type', 'application/json')
            rows = Annotations.find(@request.query).map((v)->
                v.id = v._id
                return v
            )
            @response.write(JSON.stringify({
                total : rows.length,
                rows : rows
            }))
                    
    })