setCurrentUser = (userId) =>
	@portfolioManager.currentUser = userId

Meteor.publish(null, () ->
    setCurrentUser @userId
    []
)