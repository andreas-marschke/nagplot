define([
    "jquery",
    "underscore",
    "backbone",
    "models/host"
],function($, _, Backbone, Host){
    var Hosts = Backbone.Collection.extend({
	model: Host,
	url: '/json/hosts'
    });
    return Hosts;
});