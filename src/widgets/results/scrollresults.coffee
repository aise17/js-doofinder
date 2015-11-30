###
scrollresults.coffee
author: @ecoslado
2015 11 10
###

###
Display
This class receives the search
results and paint them in a container
shaped by template. Every new page
replaces the current content.
###

ScrollDisplay = require '../scrolldisplay'

class ScrollResults extends ScrollDisplay
  ###
  constructor

  @param {String} container
  @param {String|Function} template
  @param {Object} extraOptions 
  @api public
  ###
  constructor: (container, options = {}) ->
    if not options.template
      template = '<ul>{{#each results}}' +
        '<li>{{#each this}}' +
        '<b>{{@key}}</b>:{{this}}<br>' +
        '{{/each}}</li>' +
        '{{/each}}' +
        '</ul>'
    else
      template = options.template

    super(container, template, options)

  render: (res) ->
    super(res)
    @trigger("df:results_rendered", res)

  renderNext: (res) ->
    super(res)
    @trigger("df:results_rendered", res)

module.exports = ScrollResults