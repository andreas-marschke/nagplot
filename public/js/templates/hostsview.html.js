<div id="hosts">
  <h1>Hosts</h1>
  <p> Select a host from the following </p>
  <ul id="hosts-list">
    <% hosts.each(function(host) { %>
      <li class="element host">
	<a class="host-link" href="">
	  <div class="handle">
	    <%= host.get('name') %>
	    <div class="ip">
 	      <%= host.get('ip') %>
	    </div>
	  </div>
	</a>
      </li>
    <% }); %>
  </ul>
</div>
