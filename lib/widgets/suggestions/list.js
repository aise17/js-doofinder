(function() {
  var Display, List, autoComplete,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Display = require("../display");

  autoComplete = require("doof-autocomplete");

  List = (function(superClass) {
    extend(List, superClass);

    function List(container, options) {
      if (options == null) {
        options = {};
      }
      List.__super__.constructor.call(this, container, '', options);
    }

    List.prototype.init = function(controller) {
      var self;
      this.controller = controller;
      self = this;
      this.autocomplete = this.create_autocomplete([]);
      return this.controller.bind("df:results_received", function(res) {
        if (self.autocomplete) {
          self.autocomplete.destroy();
        }
        return self.create_autocomplete(['Java', 'JavaScript', 'Javero']);
      });
    };

    List.prototype.create_autocomplete = function(choices) {
      return new autoComplete({
        selector: "#query-input",
        minChars: 1,
        source: function(term, suggest) {
          var choice, i, len, suggestions;
          term = term.toLowerCase();
          choices = [];
          suggestions = [];
          for (i = 0, len = choices.length; i < len; i++) {
            choice = choices[i];
            (choice.toLowerCase().indexOf(term) > -1 ? suggestions.push(choice) : void 0)();
          }
          return suggest(suggestions);
        }
      });
    };

    return List;

  })(Display);

  module.exports = List;

}).call(this);
