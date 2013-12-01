Portfolios = @portfolioManager.collections.Portfolios

Meteor.publish('portfolios', () ->
    Portfolios.find({}, {sort: {name: 1}})
)