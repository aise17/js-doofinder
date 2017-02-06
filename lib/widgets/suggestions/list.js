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
      window.waiting_response = false;
      window.last_result = [];
      self = this;
      this.controller.bind('df:results_received', function(res) {
        console.log('Put waiting to false: results_received');
        window.last_result = res.results.map(function(element) {
          return element.title;
        });
        return window.waiting_response = false;
      });
      this.controller.bind('df:error_received', function() {
        console.log('Put waiting to false: Error received');
        return window.waiting_response = false;
      });
      this.controller.bind('df:search', function() {
        console.log('Put waiting to true: search');
        return window.waiting_response = true;
      });
      return this.autocomplete = new autoComplete({
        selector: "#query-input",
        minChars: 1,
        source: function(term, suggest) {
          var wait;
          console.log('Waiting response');
          if (window.waiting_response === false) {
            console.log('No waiting');
            return suggest(window.last_result);
          } else {
            return wait = function() {
              console.log('Waiting...');
              if (!window.waiting_response) {
                console.log('Waiting in timeout');
                return setTimeout(function() {
                  return wait(500);
                });
              } else {
                console.log(window.last_result);
                return suggest(window.last_result);
              }
            };
          }
        }
      });
    };

    return List;

  })(Display);

  module.exports = List;

}).call(this);
