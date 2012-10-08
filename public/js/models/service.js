define([
    'jquery',
    'underscore',
    'backbone',
    'md5',
    'collections/states'
], function( $, _, Backbone,md5,States) {
    var Service = Backbone.Model.extend({
	initialize: function () {
	    _.extend(this,Backbone.Events);
	    this.attributes.States = new States({ service: this, host: this.get("parent") });
	    this.attributes.fqid = this.get('parent') + "+" + this.get('name');
	    this.attributes.hash = md5(this.get('fqid'));
	},
	getLatest : function (callback) {
	    this.get("States").fetch();
	}
    });
    return Service;
});
