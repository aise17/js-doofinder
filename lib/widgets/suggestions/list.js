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
      this.waiting_response = false;
      this.last_result = [];
      self = this;
      this.controller.bind('df:results_received', function(res) {
        self.last_result = self.get_suggestions(res);
        return self.waiting_response = false;
      });
      this.controller.bind('df:error_received', function() {
        return self.waiting_response = false;
      });
      this.controller.bind('df:search', function() {
        return self.waiting_response = true;
      });
      return this.autocomplete = new autoComplete({
        selector: "#query-input",
        minChars: 3,
        source: function(term, suggest) {
          var wait;
          if (self.waiting_response === false) {
            return suggest(self.last_result);
          } else {
            wait = function() {
              if (!self.waiting_response) {
                return setTimeout(function() {
                  return wait(500);
                });
              } else {
                return suggest(self.last_result);
              }
            };
            return wait();
          }
        }
      });
    };

    List.prototype.get_suggestions = function(res) {
      return res.results.map(function(element) {
        return element.title;
      });
    };

    return List;

  })(Display);

  module.exports = List;

}).call(this);
