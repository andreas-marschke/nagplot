# nagplot
> A nicer frontend to nagios performance data graphs

## Goal

Inspired by the design of the [c3netmon](https://github.com/FremaksGmbH/c3netmon-public) from the 28c3 and a 
discussion with my coworker about live-demoing graphs 
to a group of executives, I decided to write this [pnp4nagios](http://github.com/lingej/pnp4nagios)
frontend.

This web-app is supposed to be a graphing frontend
to the pnp4nagios performance graphs. Ultimately consisting of
a webservice providing a webpage displaying graphs with a json-rpc service
consistently feeding it.

## Implementation

The backend of this service is planned to be a pure perl application
developed with [Mojolicious](http://mojolicio.us) serving a json-rpc
service from which the clientside can picks the current state of the 
system and appends it as a new column to the current graph.

## FAQ

### But pnp4nagios already provides graphs! Why this then?

Yes pnp4nagios has graphs and they are nice to look at if you are a sysadmin.
They are not suitable though if you try to persuade a group of executives to 
invest into a new server. 

