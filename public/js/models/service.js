define([
    'jquery',
    'underscore',
    'backbone'
], function( $, _, Backbone) {
    var Service = Backbone.Model.extend({
	initialize: function () {
	    _.extend(this,Backbone.Events);
	}
    });
    return Service;
});
