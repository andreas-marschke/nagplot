;(function(undefined){

  function requestState(host,service) {
    return jQuery.getJSON('/json/query_state?host=' + host + '&service=' + service );
  }

  function requestService(host) { 
    return jQuery.getJSON('/json/services?host=' + host);
  }

  function requestHost() {
    return jQuery.getJSON('/json/hosts');
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

  setTimeout(jQuery(function(){
    requestState('ftp','check_ftp').done(updateGraph);
  }),300);

}.call(this));
