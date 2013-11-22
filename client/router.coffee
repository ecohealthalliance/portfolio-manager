Router.configure(
    layoutTemplate: 'layout'
)

Router.map () ->
    @route('home', {
        path: '/'
        template: 'list'
        after: () ->
            setSize = () ->
                navbarHeight = $('.navbar').height()
                mainHeight = window.innerHeight - navbarHeight
                $('.wrapper').height(mainHeight)
            $(window).resize(setSize)
            setTimeout(setSize, 0)
    })