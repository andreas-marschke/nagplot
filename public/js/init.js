require.config({
    // The shim config allows us to configure dependencies for
    // scripts that do not call define() to register a module
    shim: {
	'base64': {
	    exports: 'base64'
	},
	'd3': {
	    exports: 'd3'
	},
	'd3.layout': {
	    deps: [
		'd3'
	    ],
	    exports: 'd3.layout'
	},
	'rickshaw': {
	    deps: [
		'd3',
		'd3.layout'
	    ],
	    exports: 'Rickshaw'
	},
	'underscore': {
	    exports: '_'
	},
	'backbone': {
	    deps: [
		'underscore',
		'jquery'
	    ],
	    exports: 'Backbone'
	}
    },
    paths: {
	base64: 'vendor/base64',
	d3: 'vendor/d3',
	'd3.layout': 'vendor/d3.layout',
	rickshaw: 'vendor/rickshaw',
	jquery: 'vendor/jquery',
	underscore: 'vendor/underscore',
	backbone: 'vendor/backbone',
	text: 'vendor/text'
    }
});	      

require([
    'collections/hosts'
], function( Hosts ) {
    var myHosts = new Hosts();
});


