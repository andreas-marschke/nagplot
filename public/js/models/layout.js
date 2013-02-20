define([
    "jquery",
    "underscore",
    "backbone"
], function($,  _, Backbone) {
    var Layout = Backbone.Model.extend({
	defaults: {
	    id : "stub",
	    name: "Stub Layout",
	    description: "Stub Layout",
	    preview: "img/layout-icons/preview.png",
/*	    require : ["jquery","underscore","backbone"],
	    css : ["/css/bootstrap.css"], 
*/
	    js : ["/js/vendor/jquery.js"]

	},
	initialize: function(options) {
	    var that = this;
	    _.keys(this.defaults,function(key){
		that[key] = options[key] || that.defaults[key];
	    });
	}
    });
    return Layout;
});
