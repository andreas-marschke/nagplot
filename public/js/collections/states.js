define([
    "jquery",
    "underscore",
    "backbone",
    "md5",
    "rickshaw",
    "models/state"
], function($, _, Backbone, md5, Rickshaw, State) {
    var States = Backbone.Collection.extend({
	model: State,
	initialize: function (models, options) {
	    this.service = options.service;
	    this.series = new Rickshaw.Series();
	    this.url = '/json/state' 
		+ '/' + this.service.get('collection').host.get('provider') 
		+ '/' + this.service.get('collection').host.get('name') 
		+ '/' + this.service.get('name');
	}
    });
    return States;
});
