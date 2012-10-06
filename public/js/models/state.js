define([
    'jquery',
    'underscore',
    'backbone'
], function( $, _, Backbone) {
    var State = Backbone.Model.extend({
	initialize: function () {
	    _.extend(this,Backbone.Events);
	}
    });
    return State;
});