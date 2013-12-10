Router.configure(
    layoutTemplate: 'layout'
)

Router.map () ->
    @route('home', {
        path: '/'
        after: () ->
            Router.go('portfolioIcons')
    })
