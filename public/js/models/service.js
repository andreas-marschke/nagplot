define([
    'jquery',
    'underscore',
    'backbone',
    'collections/states'
], function( $, _, Backbone,States) {
    var Service = Backbone.Model.extend({
	initialize: function () {
	    _.extend(this,Backbone.Events);
	    this.attributes.States = new States({ service: this, host: this.get("parent") });
	},
	getLatest : function (callback) {
	    this.get("States").fetch();
	}
    });
    return Service;
});
