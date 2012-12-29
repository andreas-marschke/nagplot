require.config({
    // The shim config allows us to configure dependencies for
    // scripts that do not call define() to register a module
    shim: {
	'md5': {
	    exports: 'md5'
	},
	'd3': {
	    exports: 'd3'
	},
	'rickshaw': {
	    deps: [
		'd3'
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
	},
	'spin': {
	    exports: 'Spinner'
	},
    },
    paths: {
	md5: 'vendor/md5',
	d3: 'vendor/d3',
	rickshaw: 'vendor/rickshaw',
	jquery: 'vendor/jquery',
	underscore: 'vendor/underscore',
	backbone: 'vendor/backbone',
	text: 'vendor/text',
	Spinner: 'vendor/spin'
    }
});	      

require([
    'collections/hosts',
    'views/host-table',
    'Spinner',   
    "models/host"
], function( Hosts, HostTableView, Spinner, Host) {

    var hosts = new Hosts();

    var target = document.getElementById('root-spin');
    var spinner = new Spinner({
	lines: 17,
	length: 10,
	width: 2, 
	radius: 40,
	corners: 1, 
	rotate: 90,
	color: '#000',
	speed: 1,
	trail: 100,
	shadow: true,
	hwaccel: true, 
	className: 'spinner',
	zIndex: 2e9,
	top: 'auto',
	left: 'auto'
    }).spin(target);
    target.classList.add('centered');

    var view = new HostTableView({collection: hosts, el: $('#root')});
    window.hosts = hosts;
    $.ajax({
	url: '/json/init',
	type: 'GET',
	success: function(data){ 
	    _.each(data,function(host_data){
		var host = new Host(host_data);
		hosts.add(host);
	    });
	}
    });
    window.view = view;
    
});






