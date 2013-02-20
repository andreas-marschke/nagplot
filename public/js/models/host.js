define([
    "jquery",
    "underscore",
    "backbone",
    "md5",
    "collections/services",
    "models/service"
], function($, _, Backbone, md5, Services, Service) {
    /*
      SYNOPSIS: 
      var host = new Host({
        name: "localhost",
	provider: "Nagios"
      });
      console.log(host.get('metadata'));
      var services = host.get('services');
      
     */
    var Host = Backbone.Model.extend({
	initialize: function(attributes) {
	    _.extend(this,Backbone.Events);
	    this.set('hash', md5(this.get('provider') + this.get('name')));
	    this.attributes.services = new Services([], { host: this });
	    var that = this;
	    if(attributes.services.length > 0) {
		_.each(attributes.services,function(service){
		    service.collection = that.services;
		    that.attributes.services.add(new Service(service));
		});
	    }
/*	    this.get('services').on('change',  this.trigger('services-update')); */
	}
    });
    return Host;
});
