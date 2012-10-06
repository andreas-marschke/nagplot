define([
    'jquery',
    'underscore',
    'backbone',
    'base64'
], function( $, _, Backbone,base64) {
    var Host = Backbone.Model.extend({
	initialize: function () {
	    _.extend(this,Backbone.Events);
	    this.attributes.fqid = this.get('type') + "+" + this.get('provider') + "+" + this.get('name');
	},
	fqid : function(){
	    return base64.encode(this.get("fqid"),1);
	}
    });
    return Host;
});
