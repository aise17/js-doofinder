###
resultsDisplayer.coffee
author: @ecoslado
2015 11 10
###

###
ResultsDisplayer
This class receives the search
results and paint them in a container
shaped by template
###

Emitter = require 'tiny-emitter' 
emitter = new Emitter
addHelpers = require("./helpers").addHelpers
document = global.document

class Displayer

  ###
  constructor

  @param {String} container
  @param {String|Function} template
  @param {Object} extraOptions 
  @api public
  ###
  constructor: (container, template, extraOptions = {}) ->
  	@container = container
  	@handlebars = require("handlebars")
  	addHelpers @handlebars, 
      extraOptions.urlParams, 
      extraOptions.currency, 
      extraOptions.translations, 
      extraOptions.helpers
    
    if template.constructor == String
  	  @template = @handlebars.compile(template)
  	
    else if template instanceof Function
  	  @template = template
  	
    else
  	  throw Error "The provided template is not the right type. String or rendered handlebars expected."


  ###
  append

  Appends results to the older in container
  @param {Object} res
  @api public
  ###  
  append: (res) ->
    html = @template res
    document.querySelector(@container).insertAdjacentHTML('beforeend', html)
    
  ###
  replace

  Replaces the older results in container with
  the given

  @param {Object} res
  @api public
  ###  
  replace: (res) ->
    html = @template res
    document.querySelector(@container).innerHTML = html

  ###
  bind

  Method to add and event listener
  @param {String} event
  @param {Function} callback
  @api public
  ###
  bind: (event, callback) ->
    emitter.on(event, callback)

  ###
  trigger

  Method to trigger an event
  @param {String} event
  @param {Array} params
  @api public
  ###
  trigger: (event, params) -> 
    emitter.emit(event, params)

module.exports = Displayer