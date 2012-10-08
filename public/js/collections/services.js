define([
    "jquery",
    "underscore",
    "backbone",
    "models/service"
],function($, _, Backbone, Service){
    var Services = Backbone.Collection.extend({
	model: Service,
	initialize: function(attributes) {
	    this.Host = attributes.host;
	    this.url = this.url();
	},
	url: function() {
	    return '/json/services' 
		+ '/' + this.Host.get('provider')
		+ '/' + this.Host.get('name');
	}
    });
    return Services;
});