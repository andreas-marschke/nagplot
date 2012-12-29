define([
    "jquery",
    "underscore",
    "backbone",
    "collections/services"
], function($, _, Backbone, Services) {
    var ServicesCount = Backbone.View.extend({
	collection: Services,
	intialize: function() { 
	    var that = this;
	    this.collection.on('sync', function()  { 
		that.render();		
	    });
	    this.collection.on('add', function()  { 
		that.render();		
	    });
	    	    
	    this.el = document.getElementById(this.collection.host.get('hash'));
	    this.render();
	},
	render: function() {
	    console.log(this);
	    this.$el.html(this.collection.length);
	}
    });
    return ServicesCount;
});
    


