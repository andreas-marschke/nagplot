define([
    'jquery',
    'underscore',
    'backbone',
    'base64',
    'collections/hosts',
    'text!templates/hostsview.html.js'
], function ($, _, Backbone, base64, Hosts, HostViewTemplate) {
    var HostsView = Backbone.View.extend({
	collection: Hosts,
	initialize: function () {
	    _.extend(this,Backbone.Events);
	    var that = this;
	    this.collection.bind('all',function () {
		that.render();
	    });
	    this.bind("change",this.render());
	}, 
	render: function () {
	    var template =_.template(HostViewTemplate,{hosts: this.collection});
	    this.$el.html(template);
	}
    });
    return HostsView;
});
