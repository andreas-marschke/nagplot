
window.onload = setTimeout("updateGraph()",3000);
var data = {};
function updateGraph() {
	var palette = new Rickshaw.Color.Palette(),
            request = new XMLHttpRequest();

	request.open("GET", '/json', true);
	request.onreadystatechange = function () {
		var done = 4, ok = 200;
		if (request.readyState == done && request.status == ok) {
			data = request.responseText;
		}
	};
	request.send(null);

	Dumper.write(data);
/*	var graph = new Rickshaw.Graph( {
        	element: document.querySelector("#firstGraph"),
//        	width: 	document.getElementById('firstGraph').currentStyle[width],
//        	height: document.getElementById('firstGraph').currentStyle[height],
		width: 200,
		height: 200,
        	series: [ {
                	color: palette.color,
                	data:  data
	        } ]
	} );
	graph.render();
*/
}

