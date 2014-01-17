Router.map () ->
    @route('train', {
        path: '/train'
        where: 'server'
        action: () ->
            result = Meteor.call('train')
            @response.write(JSON.stringify(result))
    })

    @route('trainOnReports', {
        path: '/trainOnReports'
        where: 'server'
        action: () ->
            result = Meteor.call('trainOnReports')
            @response.write(JSON.stringify(result))
    })

    @route('diagnose', {
        path: '/diagnose'
        where: 'server'
        action: () ->
            text = @request.body.text
            if not text
                @response.writeHead(400)
            else
                @response.setHeader('Content-Type', 'application/json')
                sendProcessing = () =>
                    @response.write(' ')
                setInterval(sendProcessing, 1000)
                diagnosis = Meteor.call('diagnose', text)      
                @response.write(JSON.stringify(diagnosis))
    })