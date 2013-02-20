/*
  Allow the user to create a new dashboard or modify an existing one.
*/

define([
    "jquery",
    "ui",
    "underscore",
    "backbone",
    "text!templates/designer/wizard-init.html"
], function($, ui,  _, Backbone, WizardTemplate) {
    var Wizard = Backbone.View.extend({
	initialize: function(options) {
	    _.extend(this,Backbone.Events);
	    this.options = options || {};
	    this.render();
	},
	events : {
	    'click .new' : function() {
		this.trigger("new");
	    },
	    'click .existing': function() {
		this.trigger("existing");
	    }
	},
	hide: function() {
	    this.$el.find('#wizard-init').animate({
		top: "-400px"
	    },{
		duration: 500,
		complete: function() { 
		    $(this).remove();
		}
	    });
	},
	render: function() {
	    var template = _.template(WizardTemplate,{ designs : [] });
	    this.$el.html(template);
	}
    });
    return Wizard;
});
