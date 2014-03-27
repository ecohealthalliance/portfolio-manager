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
            _.defer ()-> $('.annotation-panel').annotator().annotator('setupPlugins', null, {
                Auth: {
                  token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3N1ZWRBdCI6IjIwMTQtMDMtMjZUMTE6MDQ6MzRaIiwiY29uc3VtZXJLZXkiOiJhYWUzYzczNzg1MmQ0Y2MxYjE1MDE3MzJhY2E4ZmFiNCIsInVzZXJJZCI6Ik5BIiwidHRsIjo4NjQwMH0.DntD2DNamuR3ka4IV_QK7swJJsnvtlP59WcO89qExqc'
                },
                Permissions: false,
                AnnotateItPermissions: {}
            });
        
        data: () ->
            Resources = portfolioManager.collections.Resources
            return {
                resource : Resources.findOne({_id: this.params._id})
            }
    })