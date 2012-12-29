define([
    "jquery",
    "underscore",
    "backbone",
    "md5",
    "collections/states"
], function($, _, Backbone, md5, States) {
    /*
      SYNOPSIS: 
      var host = new Host({ name: "localhost", provider: "nagplot" });
      var service = new Service({ name: "check_host", host: host });
      setInterval(function(){ 
        console.log(service.state());
      }, 300);
     */
    var Service = Backbone.Model.extend({
	interval: 4000,
	initialize: function() {
	    _.extend(this,Backbone.Events);
	    this.set('hash', md5( this.get('collection').host.get('provider')
				  + this.get('collection').host.get('name') 
				  + this.get('name') ));

	    this.states = new States([], { service: this });
	    this.states.on("change",this.trigger('states-change'));
	}
    });
    return Service;
});
