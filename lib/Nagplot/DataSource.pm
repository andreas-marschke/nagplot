#!/usr/bin/perl

=head1 NAME

Nagplot::DataSource - The source of all monitorable data

=head1 SYNOPSIS

 use Nagplot::DataSource;
 my $datasource = Nagplot::DataSource->new( 
   config => {
     DataSource => {
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

Nagplot Datasource is the root of all data you can pull out of a pluggable backend.
See Nagplot/DataSource/Backends.pod for more Info

=cut

package Nagplot::DataSource;

our $VERSION = '0.1';

use 5.010_000;

use strict;
use warnings;
use Moose;
use Module::Pluggable search_path => 'Nagplot::DataSource', require => 1, instantiate => 'new', except => ['Nagplot::DataSource::Dummy'];
#use Module::Pluggable search_path => 'Nagplot::DataSource', require => 1, instantiate => 'new', only => ['Nagplot::DataSource::Dummy'];

has 'config' => ( is => 'rw' , isa => 'Ref', required => 1);

sub hosts {
  my $self = shift;

  my @hosts;
  foreach my $plugin ($self->plugins(config => $self->config)) {
     push (@hosts,$plugin->hosts());
  }
  return @hosts;
}

sub services {
  my $self = shift;
  my $host = shift;

  my @services;
  foreach my $plugin ($self->plugins(config => $self->config)) {
    push (@services,$plugin->services($host));
  }
  return @services;
}

# this is very bad. (performance-wise)
# later on maybe implement a cache 
# that holds in which plugin $service
# and $host are and then just use that
# plugin to query for it.

sub query_state {
  my $self = shift;
  my $host = shift;
  my $service = shift;
  my $state;
  foreach my $plugin ($self->plugins(config => $self->config)) {
    foreach my $plugin_host ($plugin->hosts) {
      if ($plugin_host eq $host) {
	foreach my $plugin_service ($plugin->services($host)) {
	  if ($plugin_service eq $service) {
	    $state = $plugin->query_state($host, $service);
	  }
	}
      }
    }
  }
  return $state;
}

no Moose;
1;


