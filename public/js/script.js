/* Author:

*/

(function (window, document, undefined) {
    
    /*
      Wait until all templates are downloaded to start the visual part of the application
     */
    
    window.Template = Backbone.Model.extend({
	defaults: {
	    status: 0
	},
	initialize: function () {
	    _.extend(this,Backbone.Events);
	    var that = this;
	    $.ajax({
		url: this.get('el').attr('src'),
		type: 'GET',
		success: function (data,textStatus,jqXHR) {
		    that.set('status', 1);
		    that.get('el').html(data);
		}
	    });
	},
    });
    
    /* 
       Usage:
       var templates = new Templates();
       _.each($('.template').toArray(),function(element){
         templates.add({el: element});
       });
    */
    
    window.Templates = Backbone.Collection.extend({
	mode: Template,
	initialize: function(models,options) {
	    _.extend(this,Backbone.Events);
	},
	check: function() {
	    if(this.where({status: 0}).length === 0)
		this.trigger('done');
	}
    });

    window.State = Backbone.Model.extend({
	initialize: function(args) {
	    this.url = '/json/state/' + args.host + '/' + args.service;
	    this.fetch();
	}
    });
 
    window.Service = Backbone.Model.extend({
	initialize: function () {
	    this.States = [];
	    this.refresh();
	},
	refresh: function () {
	    this.States.push( new State({ host: this.get('host'), service: this.get('service')}));
	}
    });
    
    window.Services = Backbone.Collection.extend({
	model: Service,
	initialize: function (models,options) {
	    this.url = '/json/services/' + options.host
	    this.fetch();
	}
    });

    window.Host = Backbone.Model.extend({
	initialize: function () {
	    this.Services = new Services({},{host: this.get('name')});
	    this.bind('change',this.Services.fetch());
	}
    });

    window.Hosts = Backbone.Collection.extend({
	model: Host,
	url: '/json/hosts',
	initialize: function() {
	    this.fetch();
	}
    });
    
    window.HostView = Backbone.View.extend({
	tagName: 'li',
	className: 'host',
	initialize: function() {
	    this.model.bind('change',this.render());
	},
	render: function () {
	    var template = _.template($('.template#host').html(),{ host: this.model.name });
	    this.el(template);
	}
    });
    
    window.HostsView = Backbone.View.extend({
	el: $('#root'),
	initialize: function() {
	    this.bind('change',this.render());
	    this.collection.bind('change',console.log(this.collection.toJSON()));
	},
	render: function() {
	    var template = _.template($('.template#root').html());

	    // this.$el.html(hostsview_template);
	    // _.(this.collection.toArray(), function(host) {
	    // 	var HostView_ = new HostView({model: host});
	    // });
	}
    });

    /* Fill all the templates */
    var templates = new Templates();
    _.each($('.template').toArray(), function(element) { 
	templates.add(new Template({el: $(element)}));
    });

    $('.template').bind("DOMSubtreeModified",function() {
	templates.check();
    });

    templates.on('done',function() {
	var hosts = new Hosts();
	var hostsview = new HostsView({collection: hosts});
    });
   
})(this, this.document);


