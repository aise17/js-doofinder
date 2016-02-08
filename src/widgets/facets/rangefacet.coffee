###
rangefacet.coffee
author: @ecoslado
2015 11 10
###

###
RangeFacet
This class receives a facet ranges and paint 
them. Manages the filtering.
###

Display = require "../display"
$ = jQuery = require("../../util/jquery")

class RangeFacet extends Display

  constructor: (container, @name, options = {}) ->
    if not options.template
      template = '<div class="df-panel df-widget" data-facet="{{name}}">' +
        '<a href="#" class="df-panel__title" data-toggle="panel">{{label}}</a>'+
        '<div class="df-panel__content">' +
        '<input class="df-facet" type="text" name="{{name}}" value=""' +
        'data-facet="{{name}}">'+
        '</div>'+
        '</div>'
    else
      template = options.template
    @sliderOptions = options.sliderOptions
    super(container, template, options)
      

  render: (res) ->
    # Throws errors if prerrequisites are not
    # accomplished.
    if not res.facets or not res.facets[@name]
      throw Error "Error in RangeFacet: #{@name} facet is not configured."
    else if not res.facets[@name].ranges
      throw Error "Error in RangeFacet: #{@name} facet is not a range facet."

    _this = this
    if res.facets[@name].ranges[0].count > 1
      context = $.extend true, 
        name: @name, 
        @extraContext || {}

      html = @template(context)
      $(@container).html html
      range = 
        type: "double",
        min: parseInt(res.facets[@name].ranges[0].min, 10)
        from: parseInt(res.facets[@name].ranges[0].min, 10)
        max: parseInt(res.facets[@name].ranges[0].max, 10)
        to: parseInt(res.facets[@name].ranges[0].max, 10)
        force_edges: true
        prettify_enabled: true
        hide_min_max: true
        grid: true
        grid_num: 2
        onFinish: (data) ->
          _this.controller.addFilter(_this.name, {'lte': data.to, 'gte': data.from})
          _this.controller.refresh()

      range = $.extend true,
        range,
        _this.sliderOptions || {}

      if res and res.filter and res.filter.range and res.filter.range[@name] and parseInt(res.filter.range[@name].gte)
        range.from = parseInt(res.filter.range[@name].gte, 10)  
              
      if res and res.filter and res.filter.range and res.filter.range[@name] and parseInt(res.filter.range[@name].lte)
        range.to = parseInt(res.filter.range[@name].lte, 10)

      facet = $("input[data-facet='#{@name}']")
      facet.ionRangeSlider(range)
      @trigger('df:rendered', [res])

    else
      $(@container).html ""
    

  renderNext: () ->

module.exports = RangeFacet