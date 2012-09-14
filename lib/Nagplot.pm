package Nagplot;
use Mojo::Base 'Mojolicious';
use Data::Dumper;
# This method will run once at server start
sub startup {
  my $self = shift;
  $self->plugin('Config');
  $self->mode($self->config->{mode}) unless !defined $self->config->{mode};
  $self->secret($self->config->{secret}) unless !$self->config->{secret};
  # Router
  my $r = $self->routes;

  # Web Page Routing
  $r->get('/')->to(controller => 'web', action => 'dashboard');
  $r->get('/host')->to(controller => 'web', action => 'host');

  # Data Routing
  $r->get('/json/hosts')->to(controller => 'json', action => 'hosts');
  $r->get('/json/services/:host')->to(controller => 'json', action => 'services');
  $r->get('/json/state/:host/:service')->to(controller => 'json', action => 'state');

  # Config Routing
  $r->get('/config')->to(controller => 'config', action => 'config');
  $r->post('/config')->to(controller => 'config', action => 'configure');
}

1;