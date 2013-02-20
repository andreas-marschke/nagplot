define([
    "jquery",
    "ui",
    "underscore",
    "backbone",
    "rickshaw",
    "spinner",
    "collections/series",
    "collections/hosts",
    "text!templates/designer/modals/modal-tab.html",
    "text!templates/widgets/graph/hosts.html",
    "text!templates/widgets/graph/hosts-results.html",
    "text!templates/widgets/graph/service-select.html",
    "text!templates/widgets/graph/graph-config.html",
    "text!templates/widgets/graph/graph.html"
], function($, ui,  _, Backbone, Rickshaw, Spinner,
	    Series,Hosts,ModalTabTemplate,HostsTemplate,HostsResultsTemplate,
	    ServiceSelectTemplate, GraphConfigTemplate, GraphTemplate) {
    var Graph = Backbone.View.extend({
	initialize: function(options) {
	    this.options = options || {};
	    _.extend(this,Backbone.Events);
	    this.graph = {};
	    this.graph.Graph = {};
	    this.graph.pallette = new Rickshaw.Color.Palette({scheme: 'classic9'});
	    this.graph.width = 300;
	    this.graph.height = 200;
	    this.graph.series = new Series();
	    this.graph.config = {};
	    this.hosts = options.hosts;
	    this.init = false;
	},
	pages: [
	    {
		id : "hosts",
		name: "1: Hosts & Services",
		active: true,
		html : HostsTemplate
	    },
	    {
		id : "graphing",
		name: "2: Graph Configuration"
	    }
	],
	insertServices: function(host) {
	    var template = _.template(ServiceSelectTemplate,{services: host.get('services'), series: this.graph.series});
	    $(this.options.modal).find('.results').find('#' + host.get('hash') + " .accordion-inner").html(template);
	    $(this.options.modal).find('.results').find('#heading-' + host.get('hash') + " i").remove();
	},
	insertHosts: function(hosts) {
	    var results_template = _.template(HostsResultsTemplate,{hosts: hosts });
	    $(this.options.modal).find('.results').html(results_template);
	},
	filterServices: function(){
	    var that = this;
	    return _.filter($(this.options.modal).find('.service-select'),function(el){
		if ( el.checked == true ) {
		    that.hosts.each(function(host){
			if(host.get("hash").match($(el).attr('data-host'))) {
			    host.get('services').each(function(service){
				if(service.get("hash").match($(el).attr('id'))){
				    that.graph.series.add(service);
				}
			    });
			}
		    });
		    return el;
		}
		
	    });
	},
	delegateServiceSelectEvents: function(service) {
	    var that = this;
	    $('input#' + service.get('hash') + ".service-select").click(function(event){
		var filter = that.filterServices();
		if (filter.length > 0 ) {
		    that.trigger('config-done');
		} else {
		    that.trigger('config-undone');
		}
	    });
	},
	serviceFetch:function (hosts) { 
	    var that = this;
	    hosts.each(function(host){
		host.get('services').on("reset",function(){ 
		    that.insertServices(host);
		    host.get('services').each(function(service){
			that.delegateServiceSelectEvents(service);
		    });
		});
		host.get('services').fetch();
	    });	    
	},
	drawPreview: function() {
	    $('.tab-pane#graphing #preview').html('');
	    $('.tab-pane#graphing #preview').parent().find('#legend').remove();
	    var palette = new Rickshaw.Color.Palette( { scheme: this.graph.config.scheme } );

	    var seriesData = [];

	    palette.scheme.forEach( function() {
		seriesData.push([]);
	    } );

	    var random = new Rickshaw.Fixtures.RandomData(150);
	    
	    for (var i = 0; i < 100; i++) {
		random.addData(seriesData);
	    }

	    var series = [];

	    seriesData.forEach( function(s) {
		series.push( {
		    data: s,
		    color: palette.color()
		} );
	    } );

	    var previewGraph = new Rickshaw.Graph( {
		element: document.querySelector(".tab-pane#graphing #preview"),
		height: 200,
		width: 300,
		series: series
	    } );
	    
	    var x,y;
	    
	    if(this.graph.config.Xaxis) {
		x =  new Rickshaw.Graph.Axis.Time({
		    graph: previewGraph
		});
	    }

	    if (this.graph.config.Yaxis) {
		y = new Rickshaw.Graph.Axis.Y({
		    graph: previewGraph
		});
	    }
	    
	    var highlight;
	    if(this.graph.config.hover){
		highlight = new Rickshaw.Graph.HoverDetail({
		    graph: previewGraph,
		    xFormatter: function(x) { return x + "seconds" },
		    yFormatter: function(y) { return Math.floor(y) + " percent" }
		});
	    }
	    
	    previewGraph.render();
	},
	getConfig: function() {
	    return this.graph.config;
	},
	setConfig: function(conf) {
	    
	    this.graph.config = conf || {
		Xaxis: $('.tab-pane#graphing #Xaxis').attr('checked'),
		Yaxis: $('.tab-pane#graphing #Yaxis').attr('checked'),
		hover: $('.tab-pane#graphing #detail').attr('checked'),
		scheme: $('.tab-pane#graphing #colorScheme').val(),
		width: $('.tab-pane#graphing #graphWidth').val(),
		height: $('.tab-pane#graphing #graphHeight').val(),
		el: this.el,
		services: this.graph.series
	    };
	},
	start : function(){ 
	    var that = this;	    
	    var template = _.template(ModalTabTemplate,{ pages: this.pages });
	    $(this.options.modal).html(template);
	    var graph_template = _.template(GraphConfigTemplate);

	    $(this.options.modal).find('.tab-pane#graphing').html(graph_template);
	    _.each($(this.options.modal).find('.tab-pane#graphing input,select'),function(el){
		$(el).change(function(){
		    that.setConfig();
		    that.drawPreview();
		});
	    });

	    this.drawPreview();

	    $(this.options.modal).find('.search-query').change(function(event){
		var hosts = that.hosts.filter(function(host){
		    if(host.get('name').match($(that.options.modal).find('.search-query').val()) != null){
			return host;
		    }
		});
		var hostCollection = new Backbone.Collection(hosts);
		if (hosts.length > 0 ) {
		    var results_template = _.template(HostsResultsTemplate,{hosts: hostCollection });
		} else if($(event.currentTarget).val().length === 0){
		    var results_template = _.template(HostsResultsTemplate,{hosts: that.hosts });
		}
		$(that.options.modal).find('.results').html(results_template);
		that.serviceFetch(hostCollection);
	    });
	    
	    this.hosts.on('reset',function() { 
		that.insertHosts(that.hosts);
		that.serviceFetch(that.hosts);
	    });

	    if(this.hosts.length > 0) {
		this.insertHosts(that.hosts);
		this.serviceFetch(that.hosts);
	    }
	},
	render: function() {
	    this.graph.series.fetch();
	    this.$el.html('');
	    var that = this;
	    this.graph.series.on('fetched',function(){ 
		if(!that.init) {
		    console.log(that.graph.config);
		    console.log(that.graph.series);
		    that.graph.series.setPalette(that.graph.config.scheme);
		    that.graph.graph = new Rickshaw.Graph( {
			element: that.graph.config.el,
			height: that.graph.config.height,
			width: that.graph.config.width,
			series: that.graph.series.series
		    });
		    
		    var x,y;
		    
		    if(that.graph.config.Xaxis) {
			x =  new Rickshaw.Graph.Axis.Time({
			    graph: that.graph.graph
			});
		    }

		    if (that.graph.config.Yaxis) {
			y = new Rickshaw.Graph.Axis.Y({
			    graph: that.graph.graph
			});
		    }

		    var highlight;
		    if(that.graph.config.hover){
			highlight = new Rickshaw.Graph.HoverDetail({
			    graph:  that.graph.graph,
			    xFormatter: function(x) { return x + "seconds" },
			    yFormatter: function(y) { return Math.floor(y) + " percent" }
			});
		    }
		    that.graph.graph.render();
		    setTimeout(function(){
			that.update();
		    },100);
		}
		that.init = true;
	    });
	},
	update: function(){ 
	    var that = this;
	    setTimeout(function(){
		that.graph.series.each(function(service){
		    service.update();
		});
		that.graph.graph.render();
		that.update();
	    },3000);
	}	
    });
    return  Graph;
});

