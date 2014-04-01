@portfolioManager ?= {}
@portfolioManager.collections ?= {}
@portfolioManager.collections.Annotations = new Meteor.Collection('annotations')
@portfolioManager.collections.AnnotationsLog = new Meteor.Collection('annotationslog')