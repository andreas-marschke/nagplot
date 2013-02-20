define([
    "jquery",
    "ui",
    "underscore",
    "backbone",
], function($, ui,  _, Backbone) {
    var Config = Backbone.Model.extend({
	defaults : {
	    name : "default",
	    description : "default layout descriptions",
	    css: "",
	    layout :  {
		name: "3col",
		elements: {
		    "col1" : {
			widget : "text",
			config : {
			    text : "Hello World"
			}
		    },
		    "col2" : {
			widget : "text",
			config : {
			    text : "Hello World"
			}
		    },
		    "col3" : {
			widget : "text",
			config : {
			    text : "Hello World"
			}
		    },
		}
	    },
	}
    });
    return Config;
});
