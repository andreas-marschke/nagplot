define([
    'jquery',
    'underscore',
    'backbone',
    'md5',
    'collections/services'
], function( $, _, Backbone,md5,Services) {
    var Host = Backbone.Model.extend({
	initialize: function () {
	    _.extend(this,Backbone.Events);
	    this.attributes.fqid = this.get('type') + "+" + this.get('provider') + "+" + this.get('name');
	    this.attributes.Services = new Services({parent: this});
	    this.attributes.hash = md5(this.get("fqid"));
	},
	fqid : function(){
	    return md5(this.get("fqid"));
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
