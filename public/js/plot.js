;(function(undefined){

  function requestData(){
    return jQuery.getJSON('/json');
  }

  function updateGraph(response, status, jqXHR){
    var $target = jQuery('#firstGraph'),
        palette = new Rickshaw.Color.Palette(),
        graph;

    if(status === 'success'){
      graph = new Rickshaw.Graph({
        element: $target[0],
        height: $target.height(),
        width: $target.width(),
        series: [{
          color: palette.color,
          data: response
        }]
      }).render();
    } else {
      console.error('Oops, Something went wrong!', {
        'response': response,
        'status': status,
        'jqXHR': jqXHR
      });
    }
  }

  jQuery(function(){
    requestData().done(updateGraph);
  });

}.call(this));
