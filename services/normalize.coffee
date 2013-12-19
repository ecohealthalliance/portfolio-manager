@portfolioManager ?= {}
@portfolioManager.services ?= {}
@portfolioManager.services.normalize = (text) ->
    text.toLowerCase().replace(/[\.,\/#!$%\^&\*;:{}=`~()]/g,"")