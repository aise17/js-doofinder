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
      console.log('Put waiting to false: results_received')
      self.last_result = self.get_suggestions(res)
      self.waiting_response = false
    )

    @controller.bind('df:error_received', () ->
      console.log('Put waiting to false: Error received')
      self.waiting_response = false
    )

    @controller.bind('df:search', () ->
      console.log('Put waiting to true: search')
      self.waiting_response = true
    )

    @autocomplete = new autoComplete({
      selector: "#query-input",
      minChars: 3,
      source: (term, suggest) ->
        console.log('Waiting response')
        if self.waiting_response == false
          console.log('No waiting')
          suggest(self.last_result);
        else
          wait = () ->
            console.log('Waiting...')
            if !self.waiting_response
              console.log('Waiting in timeout')
              setTimeout () -> wait 500
            else
              console.log(self.last_result)
              suggest(self.last_result)
          wait()
    });

  get_suggestions: (res) ->
    return res.results.map((element) -> return element.title)

module.exports = List




