define([
    "jquery",
    "underscore",
    "backbone",
    "md5",
    "rickshaw",
    "collections/states"
], function($, _, Backbone, md5, Rickshaw, States) {
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
	    this.set('hash', md5( this.collection.host.get('provider')
				  + this.collection.host.get('name')
				  + this.get('name') ));

	    this.attributes.states = new States([], { service: this });
//	    this.attributes.states.on("change",this.trigger('states-change'));
	},
	update: function() {
	    this.get('states').fetch();
	}
    });
    
    return Service;
});
