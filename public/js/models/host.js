define([
    "jquery",
    "underscore",
    "backbone",
    "md5",
    "collections/services"
], function($, _, Backbone, md5, Services) {
    var Host = Backbone.Model.extend({
	initialize: function() {
	    this.attributes.hash = md5(
		this.get("provider") 
		    + this.get("name") 
		    + this.get("ip")
	    );
	    this.attributes.Services = new Services({host: this});
	}
    });
    return Host;
});
