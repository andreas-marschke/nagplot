define([
    "jquery",
    "underscore",
    "backbone",
    "md5",
    "models/service"
], function($, _, Backbone, md5, Service) {
    var Services = Backbone.Collection.extend({
	model: Service,
	initialize: function(models, options) {
	    this.host = options.host;
	    this.url = '/json/services/' + this.host.get('provider') + '/' + this.host.get('name');
	}
    });
    return Services;
});