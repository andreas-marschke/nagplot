define([
    "jquery",
    "ui",
    "underscore",
    "backbone",
    "views/designer/widget-configure",
    "text!templates/designer/dashboard-designer.html",
    "text!templates/common/error.html"
], function($, ui,  _, Backbone, WidgetConfiguration,DesignerTemplate,ErrorTemplate) {
    var DashboardDesigner = Backbone.View.extend({
	initialize: function(options) {
	    _.extend(this,Backbone.Events);
	    this.options = options || {};
	},
	events: {
	    "click .element": "setWidget"
	},
	setWidget: function(event){ 
	    var configuration = new WidgetConfiguration({target: event.currentTarget,
							 categories: this.options.categories,
							 hosts: this.options.hosts
							});
	    configuration.render();
	},
	render: function() {
	    var that = this;
	    var response = require(["text!"+this.options.layout.get("template")],function(LayoutTemplate){
		var template = _.template(DesignerTemplate,{layout: LayoutTemplate});
		that.$el.html(template);
		that.$el.find('.row').addClass('show-grid');
		that.$el.find('.row-fluid').addClass('show-grid');
		that.$el.find('.element').addClass('btn icon-cog');
		_.each(that.$el.find('.element'),function(element) { 
		    $(element).html("<span>" + $(element).parent().attr('id') + "</span>");
		});
	    },function (err) {
		that.$el.html(_.template(ErrorTemplate,{layout: that.options.layout }));
	    });
	}
    });
    return DashboardDesigner;
});
