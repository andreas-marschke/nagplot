#!/usr/bin/perl

=head1 NAME

Nagplot::DataSource - The source of all monitorable data

=head1 SYNOPSIS

 use Nagplot::DataSource;
 my $datasource = Nagplot::DataSource->new( 
   config => {
     DataSources => {
       enabled => [Nagios, Dummy],
       Nagios => {
  	 host => '127.0.0.1',
	 cgi_path => '/nagios/cgi-bin',
	 nagios_path => '/nagios',
	 pnp4nagios_path => '/pnp4nagios',
	 user => 'nagplot',
	 pass => 'nagplot',
	 secure => 1
        }
      }
    }
  );

 my @hosts = $datasource->hosts();
 my %services;

 foreach (@hosts) {
   $services{$_} = $datasource->services($_);
 }

 foreach my $host (keys %services) {
   foreach my $service (@{$services{$host}}) {
     print $datasource->query_state($host,$service);
   }
 }

=head1 DESCRIPTION

Nagplot Datasource is the root to all data you can pull out of a pluggable backend.
See Nagplot::Source DEVELOPER DOCUMENTATION below for more Info. Nagplot::Source is
the namespace for datasources.

=head1 CONFIGURATION

Nagplot::DataSource is configured through the DataSource key in the nagplot.conf file. It
holds the configuration for datasources and which datasources should be used by 
Nagplot::DataSource.

This segment will concentrate on the options directly available in the DtasSource hash.

=head2 enabled

An array of datasources you want to have enabled. This option will make sure that only
the relevant datasources to your setup will be enabled and running upon request, which reduces
resource hungriness if more than your requested sources are present.

=head2 cache

A string describing the caching mechanism used. If none is set Nagplot::Cache::Backend::CSV is
used.

=head1 CACHING

Nagplot::DataSource is capable of caching requests to the servers that are not relevant for 
live data such as hosts and services.

=cut

package Nagplot::DataSource;

our $VERSION = '0.1';

use 5.010_000;

use strict;
use warnings;
use Moose;
use Module::Pluggable::Object;
use Data::Dumper;

has 'config' => ( is => 'rw' , isa => 'Ref', required => 1);
has 'datasources' => ( is => 'rw' , isa => 'ArrayRef[Str]');
has 'finder' => (is => 'rw' , isa => 'Object');

# setup plugins and finder
sub BUILD {
  my $self = shift;

  $self->datasources($self->config->{enabled});
}

=head1 Nagplot::Source DEVELOPER DOCUMENTATION

This segment will focus on functions Nagpot::Source's should implement.

=head2 hosts()

Takes no parameters and returns an array of hostnames as strings.

=cut

sub hosts {
  my $self = shift;
  my @hosts;

  foreach my $source (@{$self->datasources}) {
    my $finder = Module::Pluggable::Object->new(search_path => 'Nagplot::Source',
						instantiate => 'new',
						only => "Nagplot::Source::".$source);
    foreach my $datasource ($finder->plugins(config => $self->config())) {
      push @hosts,$datasource->hosts();
    }
  }
  return @hosts;
}

=head2 services($host)

Takes the parameter $host and returns an array of services as strings. Return an empty
array if no services are available.

=cut

sub services {
  my $self = shift;
  my $host = shift;
  my @services;

  # get the list of hosts from the sources and add them to the cache
  # but only if we know the datasource is available to us
  foreach my $source (@{$self->datasources}) {
    my $finder = Module::Pluggable::Object->new(search_path => 'Nagplot::Source',
						instantiate => 'new',
						only => "Nagplot::Source::".$source);
    foreach my $datasource ($finder->plugins(config => $self->config())) {
      my @service_by_source = $datasource->services($host);
      push (@services,@service_by_source);
    }
  }
  return @services;
}

=head2 state($host, $service)

Takes the parameters $host and $service where $service is the name of the service provided
by $host and returns it's value as a scalar value. Return 0 if no value is possible 
to retrieve. 

=cut

sub state {
  my $self = shift;
  my $host = shift;
  my $service = shift;
  my $state;

  foreach my $source (@{$self->datasources}) {
    my $finder = Module::Pluggable::Object->new(search_path => 'Nagplot::Source',
						instantiate => 'new',
						only => "Nagplot::Source::".$source);
    foreach my $datasource ($finder->plugins(config => $self->config())) {
      $state = $datasource->state($host, $service);
    }
  }
  return $state;
}

no Moose;
1;





