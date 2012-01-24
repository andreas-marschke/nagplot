# TODO

## Nagplot::DataSource 

### redesign way services for a Host are queried
It's inefficient to instantiate Plugins just to find the Plugin
you fetched the the $host and *then* check **all** services for 
the one matching $service. Maybe map them?

```perl 
 %hosts = [ $plugin_name => qw/host1 host2 host3/ ];
 %service = [ $service_name => $host1 ];
```

## Nagplot::DataSource::Nagios

### Implement Service queries
You can have a few ways to implement this:

- fetch *Performance Data* row in the extinfo.cgi of nagios
  This will be a "life" only solutio (no "background" can be provided)

- fetch rrd file for the service and read the latest 
  (would also allow for pre-existing values. Which allows a look "back in time")
  Which can be realized in 2 ways _(a)_ force people to host nagplot on the **same**
  machine or _(b)_ make them serve the rrd files openly through some protocol. Be it
  http only or more is a question of implementation.
  
## More example plugins
Here are a few suggestions:

- Nagplot::DataSource::Zabbix - Another monitoring services

- Nagplot::DataSource::Cacti / ::MRTG - Monitor your links/switches

- Nagplot::DataSource::OTRS / ::RT - See how well your support team is performing

- Nagplot::DataSource::$StockExchange (its fairly flexible designed afterall)

If you'd like to: Contribute!
