(function() {
  var Display, List,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Display = require("../display");

  List = (function(superClass) {
    extend(List, superClass);

    function List(container, options) {
      var template;
      if (options == null) {
        options = {};
      }
      this.selected = -1;
      this.length = 0;
      this.maxSuggestions = options.maxSuggestions || 3;
      this.totalSuggestions = this.maxSuggestions;
      this.suggestionsSelector = options.suggestionsSelector || "li";
      this.selectedSuggestion = "";
      if (!options.template) {
        template = "<ul>\n  {{#results}}\n    <li data-term=\"{{title}}\">\n      {{title}}\n    </li>\n  {{/results}}\n</ul>";
      } else {
        template = options.template;
      }
      List.__super__.constructor.call(this, container, template, options);
    }

    List.prototype.init = function(controller) {
      var self;
      this.controller = controller;
      self = this;
      return this.controller.bind("df:results_received", function(res) {
        self.selected = -1;
        self.length = res.results.length;
        self.totalSuggestions = Math.min(self.length, self.maxSuggestions);
        return res.results.forEach(function(item, idx) {
          var i, k, ref, ref1, results;
          item.index = idx;
          console.log(idx);
          if (idx >= self.totalSuggestions) {
            results = [];
            for (k = i = ref = idx, ref1 = res.results.length - 1; ref <= ref1 ? i <= ref1 : i >= ref1; k = ref <= ref1 ? ++i : --i) {
              results.push(res.results.splice(idx, 1));
            }
            return results;
          }
        });
      });
    };

    List.prototype.next = function() {
      if (this.selectedSuggestion) {
        this.selectedSuggestion.removeClass("selected");
      }
      this.suggestions = this.element.find(this.suggestionsSelector);
      this.selected = (this.selected + 1) % this.totalSuggestions;
      this.selectedSuggestion = this.suggestions.get(this.selected).addClass("selected");
      return this.selectedTerm = this.selectedSuggestion.data("term");
    };

    List.prototype.previous = function() {
      if (this.selectedSuggestion) {
        this.selectedSuggestion.removeClass("selected");
      }
      this.suggestions = this.element.find(this.suggestionsSelector);
      if (this.selected === 0) {
        this.selected = this.totalSuggestions;
      }
      this.selected = (this.selected - 1) % this.totalSuggestions;
      this.selectedSuggestion = this.suggestions.get(this.selected).addClass("selected");
      return this.selectedTerm = this.selectedSuggestion.data("term");
    };

    List.prototype.get = function(idx) {
      if (this.selectedSuggestion) {
        this.selectedSuggestion.removeClass("selected");
      }
      this.suggestions = this.element.find(this.suggestionsSelector).addClass("selected");
      if (idx < this.totalSuggestions) {
        this.selectedSuggestion = this.suggestions.get(idx);
      }
      return this.selectedTerm = this.selectedSuggestion.data("term");
    };

    List.prototype.start = function() {
      var self;
      self = this;
      return this.controller.queryInputWidget.bind("keyup", function(e) {
        if (e.keyCode === 38) {
          self.previous();
        }
        if (e.keyCode === 40) {
          self.next();
        }
        if (e.keyCode === 13) {
          self.controller.queryInputWidget.element.val(self.selectedTerm);
          return self.controller.queryInputWidget.element.trigger("keyup");
        }
      });
    };

    return List;

  })(Display);

  module.exports = List;

}).call(this);
