define([
    "jquery",
    "underscore",
    "backbone",
    "md5",
    "rickshaw",
    "models/service"
], function($, _, Backbone, md5, Rickshaw, Service){
    var Series = Backbone.Collection.extend({
	collection: Service,
	initialize: function () {
	    _.extend(this,Backbone.Events);
            this.series = new Rickshaw.Series();
	    var that = this;
	    this.on('add',function(service){
		service.get('states').on('add',function(response){
		    that.series.addData(response);
		});
	    });
	    this.serviceFetchCount = 0;
	},
	fetch: function() {
	    var that = this;
	    this.each(function(service){
		service.get('states').on("add",function(){
		    that.trigger('fetched');
		});
		service.get('states').fetch();
	    });

	},
	setPalette: function (scheme) {
	    this.series.palette = new Rickshaw.Color.Palette( { scheme: scheme } );
	}
    });
    return Series;
});




