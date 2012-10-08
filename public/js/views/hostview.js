define([
    'jquery',
    'underscore',
    'backbone',
    'md5',
    'models/host',
    'views/servicesview',
    'text!templates/hostview.html.js'
], function ($, _, Backbone, md5, Host, ServicesView, HostViewTemplate) {
    var HostView = Backbone.View.extend({
	model: Host,
	initialize: function() {
	    _.extend(this,Backbone.Events);
	    var that = this;
	    this.model.bind('all',function() {
	    	that.render();
	    });
	    this.render();
	},
	events: {
	    "click .handle": "showServices"
	},
	showServices: function() { 
	    var id= this.model.get('hash')+"-"+"services";
	    var view = new ServicesView({el: $(id), collection: this.model.get('Services')});
	    
	},
	render : function() {
	    var template =_.template(HostViewTemplate,
				     {host: this.model});
	    this.$el.html(template);
	},
    });
    return HostView;
});

