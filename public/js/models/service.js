define([
    "jquery",
    "underscore",
    "backbone",
    "md5",
    "collections/states",
    "models/state"
], function($, _, Backbone, md5,States,State) {
    var Service = Backbone.Model.extend({
	initialize: function() {
	    this.attributes.Host = this.collection.Host;
	    this.attributes.States = new States([], { service: this } );

	}
    });
    return Service;
});
