define([
    "jquery",
    "underscore",
    "backbone",
    "md5"
], function($, _, Backbone, md5) {
    var State = Backbone.Model.extend({
	initialize: function() {
	    this.collection.series.addData(this.toJSON().data);
	}
    });
    return State;
});