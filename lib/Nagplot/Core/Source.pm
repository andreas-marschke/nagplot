#!/usr/bin/perl

=head1 NAME

Nagplot::Core::Source - Get Data from the sources

=head1 SYNOPSIS

 use Nagplot::Core::Source;

 my $object = Nagplot::Core::Source->new(...);

=head1 DESCRIPTION

=cut

package Nagplot::Core::Source;

our $VERSION = '';

use 5.010_000;

use Moose;
use Module::Pluggable::Object;
use Data::Dumper;

has 'config' => ( is => 'rw' , isa => 'Ref', required => 1);
has 'log' => ( is => 'rw', isa => 'Ref', required => 1);

sub hosts {
  my $self = shift;
  my @hosts;

  foreach my $source (@{$self->config->{Sources}->{enabled}}) {
    my $finder = Module::Pluggable::Object->new(search_path => 'Nagplot::Core::Source',
						instantiate => 'new',
						only => "Nagplot::Core::Source::".$source);
    foreach my $datasource ($finder->plugins(config => $self->config(), log => $self->log)) {
      push @hosts,$datasource->hosts();
    }
  }
  return @hosts;
}

sub services {
  my $self = shift;
  my $host = shift;
  my @services;

  foreach my $source (@{$self->config->{Sources}->{enabled}}) {
    my $finder = Module::Pluggable::Object->new(search_path => 'Nagplot::Core::Source',
						instantiate => 'new',
						only => "Nagplot::Core::Source::".$source);
    foreach my $datasource ($finder->plugins(config => $self->config(), log => $self->log)) {
      my @services = $datasource->services($host);
      return @services if  not @services == 0;
    }
  }
}

sub state {
    my $self = shift;
    my ($host,$service) = @_;

    foreach my $source (@{$self->config->{Sources}->{enabled}}) {
    my $finder = Module::Pluggable::Object->new(search_path => 'Nagplot::Core::Source',
						instantiate => 'new',
						only => "Nagplot::Core::Source::".$source);
    foreach my $datasource ($finder->plugins(config => $self->config(), log => $self->log) ) {
      return $datasource->state($host,$service);
    }
  }
}

no Moose;
1;



