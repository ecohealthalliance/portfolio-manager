$(document).ready () ->
    setSize = () ->
        navbarHeight = $('.navbar').height()
        mainHeight = window.innerHeight - navbarHeight
        $('.wrapper').height(mainHeight)
    $(window).resize(setSize)
    setSize()