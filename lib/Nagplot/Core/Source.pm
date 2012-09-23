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
has 'provider' => ( is => 'rw' , isa => 'Str');

sub hosts {
  my $self = shift;
  my @hosts;

  foreach my $source (@{$self->config->{Sources}->{enabled}}) {
    my $source_config = $self->config->{Sources}->{$source};
    if (not defined $source_config) {
      return Nagplot::Core::Types::Error->new(response => 'ErrSourceNotFound', 
					      message => "Source ".$source." is not defined in your configuration");
    }

    my $finder = Module::Pluggable::Object->new(search_path => "Nagplot::Core::Source",
						instantiate => 'new',
						only => $source_config->{Plugin});

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

  if (not defined $self->provider) {
    return Nagplot::Core::Types::Error->new(response => 'ErrProviderUndef', message => "Provider is undefined");
  }

  my $source_config = $self->config->{Sources}->{$self->provider};

  if (not defined $source_config) {
    return Nagplot::Core::Types::Error->new(response => 'ErrNoConfigFound', message => "Could not find config for ".$self->provider);
  }

  my $finder = Module::Pluggable::Object->new(search_path => 'Nagplot::Core::Source', instantiate => 'new',  only => $source_config->{Plugin});

  my @datasource = $finder->plugins(config => $source_config,
				    log => $self->log,
				    name => $self->provider
				   );

  return $datasource[0]->services($host);

}

sub state {
  my $self = shift;
  my ($host,$service) = @_;

  if (not defined $self->provider) {
    return Nagplot::Core::Types::Error->new(response => 'ErrProviderUndef', message => "Provider is undefined");
  }

  my $source_config = $self->config->{Sources}->{$self->provider};

  my $finder = Module::Pluggable::Object->new(search_path => 'Nagplot::Core::Source',
					      instantiate => 'new',
					      only => $source_config->{Plugin});

  my @datasource = $finder->plugins(config => $source_config, log => $self->log, name => $self->provider);

  return $datasource[0]->state($host,$service);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;



