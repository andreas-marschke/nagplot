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
use Nagplot::Core::Types::Error;

has 'config' => ( is => 'rw' , isa => 'Ref', required => 1);
has 'log' => ( is => 'rw', isa => 'Ref', required => 1);

sub hosts {
  my $self = shift;
  my @hosts;

  foreach my $source (@{$self->config->{Sources}->{enabled}}) {
    my $plugin = $self->config->{Sources}->{$source};
    if (not defined $plugin) {
      return Nagplot::Core::Types::Error->new(response => 'ErrSourceNotFound', 
					      message => "Source ".$source." is not defined in your configuration");
    }
    my $finder = Module::Pluggable::Object->new(search_path => 'Nagplot::Core::Source',
						instantiate => 'new',
						only => $plugin->{Plugin});

    my @datasource = $finder->plugins(config => $self->config->{Sources}->{$source},
				      log => $self->log,
				      name => $source
				     );
    push @hosts,$datasource[0]->hosts() if $datasource[0]->can("hosts");
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



