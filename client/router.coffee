Router.configure(
    layoutTemplate: 'layout'
)

Router.map () ->
    @route('portfolios', {
        path: '/'
        template: 'portfolios'
    })

    @route('build', {
        path: '/build'
        template: 'build'
    })

    @route('list', {
        path: '/list'
        template: 'list'
        after: () ->
            setSize = () ->
                navbarHeight = $('.navbar').height()
                mainHeight = window.innerHeight - navbarHeight
                $('.wrapper').height(mainHeight)
            $(window).resize(setSize)
            setTimeout(setSize, 0)
    })