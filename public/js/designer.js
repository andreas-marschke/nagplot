var RequireConfig = {
    // The shim config allows us to configure dependencies for
    // scripts that do not call define() to register a module
    shim: {
        'bootstrap': { deps: [ 'jquery' ] },
        'ui':        { deps: [ 'jquery' ] },
	'chosen':    { deps: [ 'jquery' ] },
        'underscore': { exports: '_' },
	'md5':        { exports: 'md5' },
	'd3':         { exports: 'd3' },
        'backbone': {
            deps: [
                'underscore',
                'jquery'
            ],
            exports: 'Backbone'
        },
	'rickshaw': {
	    deps: [
		'd3'
	    ],
	    exports: 'Rickshaw'
	},
	'spinner': {
	    exports: 'Spinner'
	}
    },
    paths: {
        text: 'vendor/text',
        jquery: 'vendor/jquery',
	ui: 'vendor/jquery-ui',
	spinner: 'vendor/spin',
        bootstrap: 'vendor/bootstrap',
	chosen: 'vendor/chosen.min.js',
        underscore: 'vendor/underscore',
        backbone: 'vendor/backbone',
	rickshaw: 'vendor/rickshaw',
	d3: 'vendor/d3',
	md5: 'vendor/md5',
	cssjson: 'vendor/cssjson',
    }
};
require.config(RequireConfig);
require([
    "cssjson",
    "jquery",
    "ui",
    "underscore",
    "backbone",
    "bootstrap",
    "spinner",
    "collections/hosts",
    "collections/services",
    "collections/series",
    "collections/layouts",
    "collections/widget-categories",
    "views/designer/wizard-init",
    "views/designer/layout-select",
    "views/designer/dashboard-designer",
    "text!templates/common/loading.html"
], function(cssjson,$,ui,_,Backbone, Bootstrap, Spinner, Hosts, Services, Series,
	    Layouts, WidgetCategories, Wizard, LayoutSelectDialog, DashboardDesigner,LoadingTemplate){

    var hosts = new Hosts();
    hosts.fetch();
    
    var layouts = new Layouts();
    var widgetcategories = new WidgetCategories();
   
    var spinner = new Spinner({
	lines: 13, // The number of lines to draw
	length: 7, // The length of each line
	width: 4, // The line thickness
	radius: 10, // The radius of the inner circle
	corners: 1, // Corner roundness (0..1)
	rotate: 0, // The rotation offset
	color: '#000', // #rgb or #rrggbb
	speed: 1, // Rounds per second
	trail: 60, // Afterglow percentage
	shadow: false, // Whether to render a shadow
	hwaccel: false, // Whether to use hardware acceleration
	className: 'spinner', // The CSS class to assign to the spinner
	zIndex: 2e9, // The z-index (defaults to 2000000000)
	top: 'auto', // Top position relative to parent in px
	left: 'auto' // Left position relative to parent in px
    });
    
    var wizard = new Wizard({el: $('body')});
    var layoutSelectDialog = new LayoutSelectDialog({ el: $('body'), layouts : layouts });
    var designer = new DashboardDesigner({el: $('body'), categories: widgetcategories, hosts: hosts })
    wizard.on("new",function() { 
	wizard.hide();
	layouts.fetch();

	$("body").html(LoadingTemplate);
	spinner.spin(document.getElementById('spinner'));
    });

    layouts.on("finished",function() { 
	$('#spinner').fadeOut().remove();
	layoutSelectDialog.render();
    });

    layoutSelectDialog.on('layoutselect',function(id){ 
	layoutSelectDialog.hide();
	widgetcategories.fetch();
	designer.options.layout = layouts.get(id);
	
	$("body").html(LoadingTemplate);
	spinner.spin(document.getElementById('spinner'));
    });

    widgetcategories.on("finished",function() { 
	designer.render();
    });

    wizard.render();

});

