# nagplot
A nicer frontend to nagios performance data graphs

## Goal

Inspired by the design of the [c3netmon](https://github.com/FremaksGmbH/c3netmon-public) from the 28c3 and a 
discussion with my coworker about live-demoing graphs 
to a group of executives, I decided to write this [pnp4nagios](http://github.com/lingej/pnp4nagios)
frontend.

This web-app is supposed to be a graphing frontend
to the pnp4nagios performance graphs. Ultimately consisting of
a webservice providing a webpage displaying graphs with a json-rpc service
consistently feeding it.

## Running it

Nagplot itself is a simple [Mojolicious::Lite](http://mojolicio.us) application.

### Dependencies

In addition to Mojolicious you need the following Perl modules:

 - Data::Dumper - for debugging if you wish to dive into the code
 - HTML::TableExtract - for the Nagios datasource
 - Module::Pluggable - used for the data sources
 - Moose - as OOP framework for Perl

### Configuration

After this you can pickup the nagplot.conf file and edit it to your needs.
Here is an example for if you wish to use the Nagios data source with it and have
an instance of Nagios available under the URL http://192.168.200.201/nagios :
<pre>
{
  secret => 'nagplot', # the secret your Mojolicious cookies are ecrypted with
  DataSource => {      # root config object for data sources
	Nagios => {    # a Nagios data source
		host => '192.168.200.201',
		cgi_path => '/nagios/cgi-bin',
		nagios_path => '/nagios',
		user => 'nagiosadmin', # http-basic-auth user for requesting data
		pass => 'nagiosadmin', # http-basic-auth password
		date_format => '%m-%d-%Y %T' # date_format from nagios.cfg
		secure => 0            # if you didn't configure it to be available under https use this
	}
  }
};
</pre>

Please refer to the particular Nagplot data source's documentation as to what
to define in the configuration file.

### Running

Please refer to the deployment section of the  [Mojolicious wiki](https://github.com/kraih/mojo/wiki).
For a quick run to see if it works just run: `perl nagplot daemon` and open up a webbrowser at 127.0.0.1:3000.

## How write a frontend

Nagplot provides a very easy to use json frontend to the modules. As a frontend/javascript developer 
you only need to know 3 queries:

 - `/json/hosts` - get all queriable hosts
 - `/json/services?host=$value` - get all services for a host where $value is the name of the host
 - `/json/query_state?host=$host&service=$service` - get a value describing the state


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

### But I can download my pnp4nagios graphs and put them into a document

Nagplot is not meant to be something you can copy paste into your documents. 
It is more or less like a live-broker about your facillities. So if you have a usable
backend you can plug into it to monitor devices/systems/applications. If you 
have suggestions by all means post them.
