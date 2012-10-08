<div>
  <div class="handle">
    <%= host.get('name') %>
    <div class="ip">
      <%= host.get('ip') %>
    </div>
    <div style="display:none" id="<%= host.get('hash') + '-services'%>"></div>
  </div>
</div>
