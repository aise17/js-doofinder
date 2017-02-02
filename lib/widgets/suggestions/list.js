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
      console.log("Hello");
      self = this;
      this.autocomplete = this.create_autocomplete(['Java', 'JavaScript', 'Javero']);
      console.log(autoComplete);
      return this.controller.bind("df:results_received", function(res) {
        return console.log(self.autocomplete);
      });
    };

    List.prototype.create_autocomplete = function(choices) {
      return new autoComplete({
        selector: "#query-input",
        minChars: 1,
        source: function(term, suggest) {
          term = term.toLowerCase();
          suggest(choices);
          console.log(choices);
          return console.log(suggestions);
        }
      });
    };

    return List;

  })(Display);

  module.exports = List;

}).call(this);
