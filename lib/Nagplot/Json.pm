package Nagplot::Json;
use Mojo::Base 'Mojolicious::Controller';

use Nagplot::Json::Util;
use Nagplot::Core::Source;
use Data::Dumper;

sub hosts {
  my $self = shift;
  my $json = Nagplot::Json::Util->new(log => $self->app->log);
  my $source = Nagplot::Core::Source->new(config => $self->config,
					  log => $self->app->log());

  my @array;
  foreach ($source->hosts()) {
    push @array,$json->sanitize($_);
  }
  $self->render_json(\@array);
}

sub services{
  my $self = shift;
  my $json = Nagplot::Json::Util->new(log => $self->app->log);
  my $source = Nagplot::Core::Source->new(provider => $self->stash('provider'),
					  config => $self->config,
					  log => $self->app->log);

  my @array;
  foreach ($source->services($self->stash('host'))) {
    push @array,$json->sanitize($_);
  }
  $self->render_json(\@array);
}

sub state {
  my $self = shift;
  my $json = Nagplot::Json::Util->new(log => $self->app->log);
  my $source = Nagplot::Core::Source->new(provider => $self->stash('provider'),
					  config => $self->config,
					  log => $self->app->log);

  my $state = $source->state(
    $self->stash('host'),
    $self->stash('service'));
  my $sane = $json->sanitize($state);
  $self->render_json($sane);
}

#__PACKAGE__->meta->make_immutable;
1;
