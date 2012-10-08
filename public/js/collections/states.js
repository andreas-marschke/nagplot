define([
    'jquery',
    'underscore',
    'backbone',
    'models/state'
],function($, _, Backbone, State){
    var States = Backbone.Collection.extend({
	model: State,
	initialize: function (models, options) { 
	    this.Service = options.service;
	    var that = this;
	    this.Service.bind("change",function() { 
		that.url = that.makeUrl()
	    });
	},
	fetch: function (callback) { 
	    var that = this;
	    $.ajax({
		type: 'GET',
		url: this.url,
		success: function(data) { 
		    that.add(new State(data));
		    callback;
		}
	    });
	},
	makeUrl: function() {
	    return '/json/state'
		+ '/' + this.Service.get("Host").get("provider") 
		+ '/' + this.Service.get("Host").get("name")
		+ '/' + this.Service.get("name")
	}
    });
    return States;
});