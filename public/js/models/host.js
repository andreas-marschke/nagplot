define([
    'jquery',
    'underscore',
    'backbone',
    'base64',
    'collections/services'
], function( $, _, Backbone,base64,Services) {
    var Host = Backbone.Model.extend({
	initialize: function () {
	    _.extend(this,Backbone.Events);
	    this.attributes.fqid = this.get('type') + "+" + this.get('provider') + "+" + this.get('name');
	    this.attributes.Services = new Services({parent: this});
	},
	fqid : function(){
	    return base64.encode(this.get("fqid"),1);
	},
	fetchServices : function(callback) {
	    this.get("Services").fetch({success: callback });
	},
	serviceUrl: function () {
	    return "/web/services/" + this.get('provider') + "/" + this.get('name');
	}
    });
    return Host;
});
