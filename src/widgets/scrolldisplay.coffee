###
scrolldisplay.coffee
author: @ecoslado
2015 11 10
###

###
ScrollDisplay
This class receives the search
results and paint them in a container
shaped by template. Ask for a new page
when scroll in wrapper reaches the
bottom
###

Display = require "./display"
dfScroll = require "../util/dfscroll"
$ = require "../util/jquery"

class ScrollDisplay extends Display

  ###
  constructor

  just assign wrapper property for scrolling and 
  calls super constructor.
  
  @param {String} scrollWrapper
  @param {String|Function} template
  @param {Object} extraOptions 
  @api public
  ###
  constructor: (selector, template, options) ->
    # Uses window as scroll wrapper
    if options.windowScroll
      @scrollWrapper = $(window)
      @windowScroll = true
      container = $(selector)

    # Uses an inner div as scroll wrapper
    else
      @scrollWrapper = $(selector)
      @scrollOffset = options.scrollOffset

      if not @scrollWrapper.children().length 
        # Just in case the inner element in the scroll is not given
        @scrollWrapper.prepend '<div></div>'
          
      container = @scrollWrapper.children().first()
      
      # Overrides container by defined
      if options.container
        container = options.container

    super(container, template, options)

  ###
  start

  This is the function where bind the
  events to DOM elements.
  ###
  init: (controller) ->
    _this = this
    super(controller)
    options = $.extend true,
      callback: () -> _this.controller.nextPage.call(_this.controller),
      if @scrollOffset then scrollOffset: @scrollOffset else {}

    if @windowScroll
      dfScroll options
    else
      dfScroll @scrollWrapper, options
    
    @controller.bind 'df:search df:refresh', (params) -> 
      _this.scrollWrapper.scrollTop(0)


  ###
  renderNext

  Appends results to the older in container
  @param {Object} res
  @api public
  ###  
  renderNext: (res) ->
    html = @template res
    $(@container).append html

  ###
  clean

  Cleans the container content.
  @api public
  ###
  clean: () ->
    $(@container).html ""
    

module.exports = ScrollDisplay