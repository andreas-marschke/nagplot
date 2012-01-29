# Rolling your own DataSources

DataSources are the bread and butter for nagplot. Therefore this document is
supposed to document the way you can integrate your personal monitoring system
or your setup.

## The Basics

### Configuration variables

A DataSource is configured through the _nagplot.conf_ file. In the _DataSource_
Hashref you can specify the name of your DataSource and subsequently the 
parameters you would like to pass to it. An example could look as follows:

```perl
{ DataSource => {
    MyDataSource => {
      var1 = "foo",
      var2 = 0,
      var3 = "baz"
    }
  }
}
```
An exact description of what datatypes are allowed in this file can be 
found in the Documentation of the [Config Plugin for Mojolicious](http://mojolicio.us/perldoc/Mojolicious/Plugin/Config).
The subsequent section of the _nagplot.conf_ file that is the DataSource is 
passed down to the DataSource itself. This means you as the DataSource you
can see something like this: 

```perl
{ MyDataSource => {
    var1 = "foo",
    var2 = 0,
    var3 = "baz"
  } 
}
```
### Methods

Here is a list of methods a DataSource is supposed to provide and what type of
data should be returned:

- hosts(): return an array of strings containing the names of your hosts

- services($host): return an array of strings containing the services a $host
  provides

- query_state($host,$services): return a hashref of coordinates like:
  ```perl
{x => 1222, y => 62 }
```
Additionally you should have a constructor that accepts a 'config' key pointing
to the hashref containing the configuration for the datasource.

# Examples

## in Moose

Here is a small example of how a DataSource might look like written in Moose:
```perl
package Nagplot::DataSource::MyMooseDS;

=head1 attributes

=head2 config

The configuration object from which to get 

=cut
has 'config' => (is => 'rw', isa => 'Ref');

=head2 name 

The name of your DataSource. This attribute is important since 
Module::Pluggable has no other way of telling you what plugin you are working
with.

=cut

has 'name' => (is => 'ro', isa => 'Str', default => 'MyMooseDS' );

=head2 var1 

First Datasource specific attribute

=cut

sub BUILD{
	my $self = shift;
	my %params = self->config->{$self->name};
	$self->var1(%params{var1}) unless not defined $params{var1};
        # do something initially.
}

sub hosts {
	my $self = shift;
	# do something to find all the hosts
	return @hosts;
}

sub services {
	my ($self, $host) = @_;
	# do something to find all the services
	return @services;
}

sub query_state {
	my ($self,$host,$service) = @_;
	# do something to get the current state
	return {x => $current_time, y => $current_state };
}

no Moose;
1;
```
Again this is only an example. You can return coordinates as you like as long 
as they consist of the form `{x => numeric_value, y => numeric_value}`.

Have a look at Nagplot::DataSource::Nagios for an example implementation.


