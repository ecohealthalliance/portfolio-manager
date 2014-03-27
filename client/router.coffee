Router.configure(
    layoutTemplate: 'layout'
)

Router.map () ->
    @route('home', {
        path: '/'
        after: () ->
            Router.go('splash')
    })
    @route('annotatableResource', {
        path: '/annotatableResources/:_id',
        after: () ->
            _.defer ()->
                $('.annotation-panel').annotator()
                .annotator('addPlugin', 'Unsupported')
                .annotator('addPlugin', 'Filter')
                .annotator('addPlugin', 'Store', {
                    #The endpoint of the store on your server.
                    prefix: '/annotator',
                    annotationData: {
                        'uri': window.location.href,
                        'test': true
                    }
                })
        
        data: () ->
            Resources = portfolioManager.collections.Resources
            return {
                resource : Resources.findOne({_id: this.params._id})
            }
    })