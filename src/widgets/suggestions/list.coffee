Display = require "../display"
autoComplete = require "doof-autocomplete"

class List extends Display

  constructor: (container, options={}) ->
    super(container, '', options)

  init: (@controller) ->
    console.log "Hello"
    self = this;
    @autocomplete = @create_autocomplete(['Java', 'JavaScript', 'Javero'])
    console.log(autoComplete)
    @controller.bind "df:results_received", (res) ->
      console.log(self.autocomplete)

  create_autocomplete: (choices) ->
    return new autoComplete({
      selector: "#query-input",
      minChars: 1,
      source: (term, suggest) ->
        term = term.toLowerCase();
#        suggestions = [];
#        for choice in choices
#          do if choice.toLowerCase().indexOf(term) > -1 then suggestions.push(choice);
        suggest(choices);
        console.log(choices)
        console.log(suggestions)
    });
module.exports = List




