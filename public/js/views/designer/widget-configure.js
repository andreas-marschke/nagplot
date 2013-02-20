define([
    "jquery",
    "ui",
    "underscore",
    "backbone",
    "bootstrap",
    "text!templates/designer/modals/widget-config.html"
], function($, ui,  _, Backbone, Bootstrap, ModalTemplate) {
    var WidgetConfiguration = Backbone.View.extend({
	initialize: function(options){ 
	    _.extend(this,Backbone.Events);
	    this.options = options || {};
	},
	events: {
	    "click .widget" : "widgetSelect",
	    "click .save" : "save",
	    "click .close-modal": "close",
	    "click .close": "close"
	},
	widgetSelect : function(event) {
	    var widget = this.options.categories.getWidgetById($(event.currentTarget).attr("id"));

	    var that = this;
	    require([widget.get("script")],function(Script){
		var script = new Script({ el: $(that.options.target).parent() ,
					  modal: that.$el.find('.modal-body') ,
					  hosts: that.options.hosts
					});
		script.on('config-done',function(){ 
		    that.$el.find('.save').removeClass('disabled');
		});
		script.on('config-undone',function(){ 
		    that.$el.find('.save').addClass('disabled');
		});
		script.start();
		that.$el.find('.save').click(function(ev){
		    if (!ev.currentTarget.classList.contains("disabled")) {
			script.setConfig();
			script.trigger('saved');
		    }
		});
		script.on('saved',function(){
		    script.render();
		});
	    });
	},
	close : function() {
	    this.$el.modal('hide');	    
	},
	save : function() {
	    this.$el.modal('hide');
	},
	render : function () {
	    var template = _.template(ModalTemplate,{categories: this.options.categories });
	    $('body').append(template);
	    this.setElement($('#designer-widget-modal').modal('show'));
	    var that = this;
	    this.$el.on('hide',function(event) {
		/* circumvent accordion events bubbling up */
		if($(event.target).hasClass('accordion-body')) { 
		    return;
		}
		that.$el.remove();
	    });
	}
    });
    return WidgetConfiguration;
});
