define([
    "jquery",
    "underscore",
    "backbone",
    "collections/hosts",
    "views/services-count",
    "text!templates/host-table.html",
    "text!templates/no-elements-warn.html"
], function($, _, Backbone, Hosts, ServicesCount, HostTableTemplate, NoElements) {
    var HostTableView = Backbone.View.extend({
	collection: Hosts,
	initialize: function() {
	    var that = this;
	    _.extend(this,Backbone.Events);
	    this.filter = '*';

	    this.collection.on('sync',function() { 
		that.render();
	    });
	    this.collection.on('add', function() {
		that.render();
	    });

	},
	events: {
	    "submit #nagplot-host-search-form" : "updateFilter",
	    "click #nagplot-host-table-refresh" : "fetchCollection" 
	},
	updateFilter: function() {
	    this.render($('.form-search input.search-query').val());
	    return false;
	},
	fetchCollection : function() {
	    var that = this;

	    this.collection.fetch({
		success: function() {
		    console.log(that.collection);
		    that.collection.each(function(host){
			host.services.fetch();
		    });
		}
	    });
	},
	render: function(filter) {
	    var template;
	    var hosts = this.collection.toArray();
	    var that = this;
	    if( filter != undefined ) {
		hosts = this.collection.filter(
		    function(element){ 
			if(element.get('name').match(filter) != undefined) {
			    return element;
			}
		    });
	    }
	    
	    template = _.template(HostTableTemplate,{ hosts : hosts });
	    this.$el.html(template);
	    if(hosts.length < 1) { 
		var warn = _.template(NoElements, {filter: filter });
		this.$el.append(warn);
	    }
	    this.collection.each(function(host){ 
		var el = $('#' + host.get('hash'));
		el.html(host.services.length);
	    });
	}
    });
    return HostTableView;
});
