Router.configure(
    layoutTemplate: 'layout'
)

Router.map () ->
    @route('portfolios', {
        path: '/'
        template: 'portfolios'
        before: () ->
            Session.set('selectedResource', null)
            Session.set('selectedPortfolio', null)
    })

    @route('build', {
        path: '/build'
        template: 'build'
    })

    @route('list', {
        path: '/list/:_id'
        template: 'list'
        before: () ->
            Session.set('selectedResource', null)
            Session.set('selectedPortfolio', @params._id)
        after: () ->
            setSize = () ->
                navbarHeight = $('.navbar').height()
                mainHeight = window.innerHeight - navbarHeight
                $('.wrapper').height(mainHeight)
            $(window).resize(setSize)
            setTimeout(setSize, 0)
    })