define([
    "jquery",
    "underscore",
    "backbone",
    "md5"
], function($, _, Backbone, md5) {
    var State = Backbone.Model.extend({
	initialize: function() {
	    this.collection.trigger('add',this.toJSON().data);
	}
    });
    return State;
});