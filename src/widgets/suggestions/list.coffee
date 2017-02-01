Display = require "../display"

class List extends Display

  constructor: (container, options={}) ->
    @selected = -1
    @length = 0
    @maxSuggestions = options.maxSuggestions || 3
    @totalSuggestions = @maxSuggestions
    @suggestionsSelector = options.suggestionsSelector || "li"
    @selectedSuggestion = ""

    if not options.template
      template = """
        <ul>
          {{#results}}
            <li data-term="{{title}}">
              {{title}}
            </li>
          {{/results}}
        </ul>
      """
    else
      template = options.template
    super(container, template, options)

  init: (@controller) ->
    self = this
    @controller.bind "df:results_received", (res) ->
      self.selected = -1
      self.length = res.results.length
      self.totalSuggestions = Math.min(self.length, self.maxSuggestions)
      # Removes the unused results
      res.results.forEach (item, idx) ->
        item.index = idx
        console.log idx
        if idx >= self.totalSuggestions
          for k in [idx .. res.results.length - 1]
            res.results.splice(idx, 1)
      

  next: () ->
    if @selectedSuggestion
      @selectedSuggestion.removeClass("selected")
    @suggestions = @element.find(@suggestionsSelector)
    @selected = (@selected + 1) % @totalSuggestions
    @selectedSuggestion = @suggestions.get(@selected).addClass("selected")
    @selectedTerm = @selectedSuggestion.data("term")

  previous: () ->
    if @selectedSuggestion
      @selectedSuggestion.removeClass("selected")
    @suggestions = @element.find(@suggestionsSelector)
    if(@selected == 0)
      @selected = @totalSuggestions
    @selected = (@selected - 1) % @totalSuggestions
    @selectedSuggestion = @suggestions.get(@selected).addClass("selected")
    @selectedTerm = @selectedSuggestion.data("term")

  get: (idx) ->
    if @selectedSuggestion
      @selectedSuggestion.removeClass("selected")
    @suggestions = @element.find(@suggestionsSelector).addClass("selected")
    if idx < @totalSuggestions
      @selectedSuggestion = @suggestions.get(idx)
    @selectedTerm = @selectedSuggestion.data("term")

  start: () ->
    self = this
    @controller.queryInputWidget.bind "keyup", (e) -> 
      if e.keyCode == 38
        self.previous()
      if e.keyCode == 40
        self.next()
      if e.keyCode == 13
        self.controller.queryInputWidget.element.val(self.selectedTerm)
        self.controller.queryInputWidget.element.trigger("keyup")

module.exports = List




