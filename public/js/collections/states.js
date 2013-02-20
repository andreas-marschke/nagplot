define([
    "jquery",
    "underscore",
    "backbone",
    "md5",
    "models/state"
], function($, _, Backbone, md5, State) {
    var States = Backbone.Collection.extend({
	model: State,
	initialize: function (models, options) {
	    this.service = options.service;
	    this.url = '/json/state' 
		+ '/' + this.service.collection.host.get('provider') 
		+ '/' + this.service.collection.host.get('name') 
		+ '/' + this.service.get('name');
	    var that = this;
	},
    });
    return States;
});

