define([
    'jquery',
    'underscore',
    'backbone',
    'models/state'
], function( $, _, Backbone,State) {
    var States = Backbone.Collection.extend({
	initialize: function (attributes) {
	    _.extend(this,Backbone.Events);
	    this.data = [];
	    this.service = attributes.service;
	    this.host = attributes.host;
	},
	url : function () {
	    return '/json/state/' 
		+ this.host.get('provider') 
		+ "/" + this.host.get('name') 
		+ "/" + this.service.get('name');
	},
	fetch : function() {
	    $.ajax({
		type: 'GET',
		url: this.url(),
		success: function(attributes) {
//		    console.log(attributes);
		}
	    });
	},
	toSeries: function () {
	}
    });
    return States;
});
