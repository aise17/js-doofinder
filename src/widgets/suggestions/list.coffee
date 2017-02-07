Display = require "../display"
autoComplete = require "doof-autocomplete"

class List extends Display

  constructor: (container, options={}) ->
    super(container, '', options)

  init: (@controller) ->
    @waiting_response = false
    @last_result = []
    self = this;

    @controller.bind('df:results_received', (res) ->
      self.last_result = self.get_suggestions(res)
      self.waiting_response = false
    )

    @controller.bind('df:error_received', () ->
      self.waiting_response = false
    )

    @controller.bind('df:search', () ->
      self.waiting_response = true
    )

    @autocomplete = new autoComplete({
      selector: "#query-input",
      minChars: 2,
      source: (term, suggest) ->
        if self.waiting_response == false
          suggest(self.last_result);
        else
          wait = () ->
            if !self.waiting_response
              setTimeout () -> wait 500
            else
              suggest(self.last_result)
          wait()
    });

  get_suggestions: (res) ->
    return res.results.map((element) -> return element.title).slice(0,2)

module.exports = List




