define([
    'jquery',
    'underscore',
    'backbone',
    'md5',
    'collections/hosts',
    'views/hostview',
    'text!templates/hostsview.html.js'
], function ($, _, Backbone, md5, Hosts, HostView, HostsViewTemplate) {
    var HostsView = Backbone.View.extend({
	collection: Hosts,
	initialize: function () {
	    _.extend(this,Backbone.Events);
	    var that = this;
	    this.collection.bind('all',function () {
		that.render();
	    });
	    this.bind("change",this.render());
	    this.hostviews = [];
	}, 
	render: function () {
	    var template =_.template(
		HostsViewTemplate, { 
		    hosts: this.collection,
		    HostView: HostView
		});
	    this.$el.html(template);
	    var that = this;
	    _.each($('ul#hosts-list li').toArray(), function(element){
		var host = that.collection.where({ hash: $(element).attr("id") })[0];
		hostview = new HostView({model: host, el: element});
		hostview.render();
	    });
	}
    });
    return HostsView;
});
