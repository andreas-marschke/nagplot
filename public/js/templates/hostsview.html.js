<div id="hosts">
  <h1>Hosts</h1>
  <p> Select a host from the following </p>
  <ul id="hosts-list">
    <% hosts.each(function(host) { %>
      <li id="<%= host.fqid() %>"></li>
    <% }); %>
  </ul>
</div>
