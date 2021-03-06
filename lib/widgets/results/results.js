
/*
display.coffee
author: @ecoslado
2015 11 10
 */


/*
Display
This class receives the search
results and paint them in a container
shaped by template. Every new page
replaces the current content.
 */

(function() {
  var Display, Results,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Display = require('../display');

  Results = (function(superClass) {
    extend(Results, superClass);


    /*
    constructor
    
    @param {String} container
    @param {String|Function} template
    @param {Object} extraOptions
    @api public
     */

    function Results(container, options) {
      var template;
      if (options == null) {
        options = {};
      }
      if (!options.template) {
        template = "<ul>\n  {{#results}}\n    <li>\n      <b>{{title}}</b>: {{description}}\n    </li>\n  {{/results}}\n</ul>";
      } else {
        template = options.template;
      }
      Results.__super__.constructor.call(this, container, template, options);
    }

    return Results;

  })(Display);

  module.exports = Results;

}).call(this);
