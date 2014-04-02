resourceTemplate = (resource) ->
    """
    <!DOCTYPE html>
    <html>
    <head>
    <script src="/3p/jquery.min.js"></script>
    <link href="/3p/annotator-full/annotator.min.css" rel="stylesheet" type="text/css" />
    <script src="/3p/annotator-full/annotator-full.min.js"></script>
    <script>
    $(function(){
        var annotator = new Annotator($('.resource')[0]);
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
    <style>
    .resource {
        max-width: 500px;
        margin: auto;
    }
    </style>
      <meta charset="utf-8">
      <title>Annotator</title>
    </head>
    <body class="resource">#{resource.content}</body>
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
