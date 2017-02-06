Display = require "../display"
autoComplete = require "doof-autocomplete"

class List extends Display

  constructor: (container, options={}) ->
    super(container, '', options)

  init: (@controller) ->
    window.waiting_response = false
    window.last_result = []
    self = this;

    @controller.bind('df:results_received', (res) ->
      console.log('Put waiting to false: results_received')
      window.last_result = res.results.map((element) -> return element.title)
      window.waiting_response = false
    )

    @controller.bind('df:error_received', () ->
      console.log('Put waiting to false: Error received')
      window.waiting_response = false
    )

    @controller.bind('df:search', () ->
      console.log('Put waiting to true: search')
      window.waiting_response = true
    )

    @autocomplete = new autoComplete({
      selector: "#query-input",
      minChars: 1,
      source: (term, suggest) ->
        console.log('Waiting response')
        if window.waiting_response == false
          console.log('No waiting')
          suggest(window.last_result);
        else
          wait = () ->
            console.log('Waiting...')
            if !window.waiting_response
              console.log('Waiting in timeout')
              setTimeout () -> wait 500
            else
              console.log(window.last_result)
              suggest(window.last_result)
    });

module.exports = List




