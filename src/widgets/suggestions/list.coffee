Display = require "../display"
autoComplete = require "doof-autocomplete"

class List extends Display

  constructor: (container, options={}) ->
    super(container, '', options)

  init: (@controller) ->
    self = this;
    @autocomplete = @create_autocomplete([])

    @controller.bind "df:results_received", (res) ->
      self.autocomplete.destroy() if self.autocomplete
      self.create_autocomplete(['Java', 'JavaScript', 'Javero'])

  create_autocomplete: (choices) ->
    return new autoComplete({
      selector: "#query-input",
      minChars: 1,
      source: (term, suggest) ->
        term = term.toLowerCase();
        choices = [];
        suggestions = [];
        for choice in choices
          do if choice.toLowerCase().indexOf(term) > -1 then suggestions.push(choice);
        suggest(suggestions);
    });
module.exports = List




