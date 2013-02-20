define([
    "jquery",
    "ui",
    "underscore",
    "backbone",
    "text!templates/designer/layout-select.html"
], function($, ui,  _, Backbone, DialogTemplate) {
    var LayoutSelectDialog = Backbone.View.extend({
	initialize: function(options) {
	    _.extend(this,Backbone.Events);
	    this.options = options || {};
	},
	events : { 
	    "click .layout" : "layoutselect"
	},
	hide: function() {
	    this.$el.find('#layout-select').animate({
		top: "-400px"
	    },{
		duration: 500,
		complete: function() { 
		    $(this).remove();
		}
	    });
	},
	layoutselect : function (event) {
	    this.trigger("layoutselect",$(event.currentTarget).attr("id"));
	},
	render: function() { 
	    var template = _.template(DialogTemplate,{layouts: this.options.layouts});
	    this.$el.html(template);
	}
    });
    return LayoutSelectDialog;
});
