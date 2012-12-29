define([
    "jquery",
    "underscore",
    "backbone",
    "md5",
    "text!templates/graph.html"
], function($, _, Backbone, md5, GraphTemplate) {
    var Graph = Backbone.View.extend({
	collection: States,
	initialize: function(options) {
	    this.options.scheme = options.scheme || "classic9";
	    this.collection.on('all',this.render());
	},
	render: function() {
	    var template = _.template(GraphTemplate,{id: this.collection.service.get('hash')});
	    this.$el.append(template);
	    
	}
    });
    return Graph;
});
