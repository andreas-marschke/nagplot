# Nagplot and JSON-RPC

For the frontend nagplot provides URLs to communicate with the datasources and
request data you (as the webdeveloper) can display.

## Data retrival

The following items describe the URLs from which you can retrieve data and which form they are:

### /json/hosts

- description: a list of hostnames
- params: has no parameters.
- return: an array of host names like: ```["localhost","ftp","www"]```

### /json/services?host=$host

- description: a list of services for a host
- params: $host - instert the hostname you previously retrieved with /json/host
- return: an array of services you can map to the host. 
  Example: ```["check_http","check_ftp","check_ping"]```

### /json/checkstate?host=$host&services=$service

- description: a coordinate for the service data
- params:
  - $host - see above
  - $service - the service from /json/services?...
- returns a coordinate data point for the service like this: ```{"y":44.5438940835402,"x":1}```

# Nagplot and rebranding

For a general overview of how to customize the design, [have a look](https://github.com/kraih/mojo/wiki/Working-with-the-templating-system) [at the](http://mojolicio.us/perldoc/Mojolicious/Plugin/DefaultHelpers)
[Mojolicious documentation](http://mojolicio.us/perldoc/Mojo/Template).

## In short

Under `public/` you can find the css,javascript and image sources for your
perusal. Besides that you can find the templates and the basic layout under
`template/` and `template/layout/` respectively. Have fun customizing. ;)
