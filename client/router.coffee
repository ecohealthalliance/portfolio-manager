Router.configure(
    layoutTemplate: 'layout'
)

Router.map () ->
    @route('home', {
        path: '/'
        after: () ->
            Router.go('portfolios')
    })

    @route('portfolios', {
        path: '/portfolios'
        before: () ->
            Session.set('selectedResource', null)
            Session.set('selectedPortfolio', null)
    })

    @route('build', {
        path: '/build'
    })

    @route('list', {
        path: '/list/:_id'
        before: () ->
            Session.set('selectedResource', null)
            Session.set('selectedPortfolio', @params._id)
        after: () ->
            setSize = () ->
                navbarHeight = $('.navbar').height()
                mainHeight = window.innerHeight - navbarHeight
                $('.wrapper').height(mainHeight)
                portfolioInfoHeight = $('#portfolio-info').height()
                resourcesListHeight = mainHeight - portfolioInfoHeight
                $('#resources-list-wrapper').height(resourcesListHeight)
            $(window).resize(setSize)
            setTimeout(setSize, 0)
    })