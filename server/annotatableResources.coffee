resourceTemplate = (resource) ->
    """
    <!DOCTYPE html>
    <html>
    <head>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
    <link href="/annotator-full/annotator.min.css" rel="stylesheet" type="text/css" />
    <script src="/annotator-full/annotator-full.min.js"></script>
    <script>
    $(function(){
        var annotator = new Annotator($('body')[0]);
        annotator.addPlugin('Unsupported');
        annotator.addPlugin('Filter');
        annotator.addPlugin('Store', {
            prefix: '/annotator',
            annotationData: {
                uri: window.location.href,
                resourceId: "#{resource._id}",
                test: true
            },
            loadFromSearch: {
                'uri': window.location.href
            }
        });
        /*
        annotator.addPlugin('Categories', {
            cata : 'cata'
            catb : 'catb'
        });
        */
    });
    </script>
      <meta charset="utf-8">
      <title>Annotator</title>
    </head>
    <body>#{resource.content}</body>
    </html>
    """

Router.map () ->    
    #This route serves non-reactive pages with
    #the resource text and annotator plug-in
    #using some of the underlying node primatives.
    @route 'annotatableResources',
        path: 'annotatableResources/:_id'
        where: 'server'
        action: () ->
            resource = portfolioManager.collections.Resources.findOne(_id: @params._id)
            if resource?
                @response.write(resourceTemplate(resource))
            else
                console.log "Couldn't load : #{@params._id}"
                @response.writeHead(404, "NOT FOUND")
