define([
    "jquery",
    "underscore",
    "backbone",
    "models/widget-category"
], function($,  _, Backbone,WidgetCategory) {
    var Widgets = Backbone.Collection.extend({
	model: WidgetCategory,
	url: "/data/widgets",
	initialize: function() {
	    _.extend(this,Backbone.Events);
	},
	fetch: function (callback) {
	    var that = this;
	    $.ajax({
		url: this.url,
		type: "GET",
		success: function(data) {
		    that.add(data);
		    that.trigger("finished");
		}
	    });
	},
	getWidgetById: function(id) {
	    var widget;
	    this.each(function(category) {  
		/* Make sure we don't accidentally overwrite it with undefined by iterating */
		if (widget != undefined)
		    return;
		widget = category.get("elements").get(id);
	    });
	    return widget;
	    
	}
    });
    return Widgets;
});
