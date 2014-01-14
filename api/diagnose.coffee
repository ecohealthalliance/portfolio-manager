Router.map () ->
    @route('diagnose', {
        path: '/diagnose'
        where: 'server'
        action: () ->
            text = @request.body.text
            if not text
                @response.writeHead(400)
            else
                diagnosis = Meteor.call('diagnose', text)
                @response.setHeader('Content-Type', 'application/json')
                @response.write(JSON.stringify(diagnosis))
    })