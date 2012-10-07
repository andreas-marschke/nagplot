define([
    'jquery',
    'underscore',
    'backbone',
    'models/service'
], function( $, _, Backbone,Service) {
    var Services = Backbone.Collection.extend({
	model: Service,
	initialize: function (attributes) {
	    _.extend(this,Backbone.Events);
	    this.parent = attributes.parent;
	},
	url: function () {
	    return '/json/services/'+ this.parent.get('provider') + "/" + this.parent.get('name');
	}
    });
    return Services;
});