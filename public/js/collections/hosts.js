define([
    "jquery",
    "underscore",
    "backbone",
    "md5",
    "models/host"
], function($, _, Backbone, md5, Host) {
    
    /*
      SYNOPSIS:
      var hosts = new Hosts();
      hosts.fetch();
     */
    
    var Hosts = Backbone.Collection.extend({
	model: Host,
	url: '/json/hosts',
	initialize: function() {
	    _.extend(this,Backbone.Events);
	}
    });
    return Hosts;
});