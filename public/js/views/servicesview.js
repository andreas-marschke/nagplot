define([
    'jquery',
    'underscore',
    'backbone',
    'md5',
    'collections/services',
    'text!templates/servicesview.html.js'
], function ($, _, Backbone, Services, ServicesViewTemplate) {
    var ServicesView = Backbone.View.extend({
	collection: Services,
	initialize: function() {
	    _.extend(this,Backbone.Events);
	    var that = this;
	    this.collection.bind('all',function () {
		that.render();
	    });
	    this.render();
	},
	events: {
	    "click .handle": "popOut"
	},
	render : function() {
	    var template =_.template(ServicesViewTemplate,
				     {host: this.model});
	    this.$el.html(template);
	},
    });
    return ServiceView;
});

