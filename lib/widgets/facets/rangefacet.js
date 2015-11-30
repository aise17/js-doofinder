
/*
rangefacet.coffee
author: @ecoslado
2015 11 10
 */


/*
RangeFacet
This class receives a facet ranges and paint 
them. Manages the filtering.
 */

(function() {
  var $, Display, RangeFacet, jQuery,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Display = require("../display");

  $ = jQuery = require("../../util/jquery");

  RangeFacet = (function(superClass) {
    extend(RangeFacet, superClass);

    function RangeFacet(container, name, options) {
      var template;
      this.name = name;
      if (options == null) {
        options = {};
      }
      if (!options.template) {
        template = '<div class="df-panel df-widget" data-facet="key">' + '<a href="#" class="df-panel__title" data-toggle="panel">{{label}}</a>' + '<div class="df-panel__content">' + '<input class="df-facet" type="text" name="{{name}}" value=""' + 'data-facet="range" data-key="{{name}}">' + '</div>' + '</div>';
      } else {
        template = options.template;
      }
      RangeFacet.__super__.constructor.call(this, container, template, options);
    }

    RangeFacet.prototype.render = function(res) {
      var _this, context, facet, html, range;
      if (!res.facets || !res.facets[this.name]) {
        throw Error("Error in RangeFacet: " + this.name + " facet is not configured.");
      } else if (!res.facets[this.name].ranges) {
        throw Error("Error in RangeFacet: " + this.name + " facet is not a range facet.");
      }
      _this = this;
      context = $.extend(true, {
        name: this.name
      }, this.extraContext || {});
      html = this.template(context);
      $(this.container).html(html);
      range = {
        type: "double",
        min: parseInt(res.facets[this.name].ranges[0].min, 10),
        from: parseInt(res.facets[this.name].ranges[0].min, 10),
        max: parseInt(res.facets[this.name].ranges[0].max, 10),
        to: parseInt(res.facets[this.name].ranges[0].max, 10),
        force_edges: true,
        prettify_enabled: true,
        hide_min_max: true,
        grid: true,
        grid_num: 2,
        onFinish: function(data) {
          _this.controller.addFilter(_this.name, {
            'lt': data.to,
            'gte': data.from
          });
          return _this.controller.refresh();
        }
      };
      if (res && res.filter && res.filter.range && res.filter.range[this.name] && parseInt(res.filter.range[this.name].gte)) {
        range.from = parseInt(res.filter.range[this.name].gte, 10);
      }
      if (res && res.filter && res.filter.range && res.filter.range[this.name] && parseInt(res.filter.range[this.name].lt)) {
        range.to = parseInt(res.filter.range[this.name].lt, 10);
      }
      facet = $("input[data-key='" + this.name + "']");
      return facet.ionRangeSlider(range);
    };

    RangeFacet.prototype.renderNext = function() {};

    return RangeFacet;

  })(Display);

  module.exports = RangeFacet;

}).call(this);