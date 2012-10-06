define([
    'jquery',
    'underscore',
    'backbone',
    'models/host'
], function( $, _, Backbone,Host) {
    var Hosts = Backbone.Collection.extend({
	model: Host,
	initialize: function () {
	    _.extend(this,Backbone.Events);
	},
	url: '/json/hosts'
    });
    return Hosts;
});

