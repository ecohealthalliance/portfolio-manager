getTags = () =>
    (tag.name for tag in @portfolioManager.Tags.find().fetch())

Template.search.helpers(
    query: () ->
        Session.get('query')
)

Template.search.events(
    'submit #search-form': (event) ->
        query = $('.search-query').val()
        Session.set('query', query)
        false
)

Template.search.rendered = () ->
    $('.search-query').typeahead(
        source: getTags
    )