
#!/usr/bin/perl

=head1 NAME

Nagplot::DataSource::Cache - a caching object for hosts services and states

=head1 SYNOPSIS

 use Nagplot::DataSource::Cache;

 my $cache = Nagplot::DataSource::Cache->new();

=head1 DESCRIPTION

You can store your host and service information in here in order to not query the
datasource everytime. This will reduce resource hogging for services we request
information from.

=cut

package Nagplot::DataSource::Cache;

our $VERSION = '';

use 5.010_000;

use strict;
use warnings;
use Moose;
use Data::Dumper;

=head1 ATTRIBUTES

=head2 hosts

A hashref of hosts where the host is the key and the plugin is the value

=cut

has 'hosts' => ( is => 'rw' , isa => 'HashRef[Str]');

=head2 services

A hashref of services where the key is the hostname followed by a dash and the service name
holding the datasource name as the value.

=cut

has 'services' => ( is => 'rw' , isa => 'HashRef[Str]');

has 'state' => ( is => 'rw' , isa => '');


=head1 where_is

Find out which host and/or service belongs to which plugin

parameters are: where_is($type ,$host , $service);
where type can be either 'host' or 'service'.
If it is service you will need to add the $service option as well.
Otherwise set the $host parameter only.

=cut


sub where_is {
  my $self = shift;
  my $type = shift;
  if ($type =~ m/host/) {
    return $self->hosts->{shift};
  } elsif ($type =~ m/service/) {
    my ($host,$service) = @_;
    return $self->services->{$host.'-'.$service};
  }
}

=head1 add_host

Add a host to the list of hosts

=cut

sub add_host () {
  my ($self,$host,$plugin) = @_;
  $self->hosts->{$host}($plugin);
  return 0;
}

=head1 add_service

Add a service to the list of services

=cut

sub add_service () {
  my ($self,$host,$service,$plugin) = @_;
  $self->services->{$host.'-'.$service}($plugin);
  return 0;
}

=head1 delete_host

remove hosts from the list. This will remove services referencing this host as well

=cut

sub delete_host () {
  my ($self,$host) = shift;
  delete $self->hosts->{$host};
  foreach my $key (keys $self->services) {
    if ($key =~ m/^$host-.*/) {
      delete $self->services->{$key};
    }
  }
}

=head1 delete_service

Remove service from the services table. This will not affect the host

=cut

sub delete_service () {
  my ($self, $host, $service) = shift;
  delete $self->services->{$host.'-'.$service};
}

no Moose;
1;
