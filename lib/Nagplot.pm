package Nagplot;
use Mojo::Base 'Mojolicious';
use Data::Dumper;
use Module::Pluggable::Object;

# This method will run once at server start
sub startup {
  my $self = shift;
  $self->plugin('Config');
  $self->mode($self->config->{mode}) unless !defined $self->config->{mode};
  $self->secret($self->config->{secret}) unless !$self->config->{secret};

  # Sanity check config values
  foreach (@{$self->config->{Sources}->{enabled}}) {
    if (not defined $self->config->{Sources}->{$_}) {
      $self->log->error("Error: ".$_." is not defined in Sources configuration");
    }
  }
  
  # Router
  my $r = $self->routes;

  # Web Page Routing
  $r->get('/')->to(controller => 'web', action => 'dashboard');
  $r->get('/host')->to(controller => 'web', action => 'host');

  # Data Routing
  $r->get('/json/hosts')->to(controller => 'json', action => 'hosts');
  $r->get('/json/services/:provider/:host')->to(controller => 'json', action => 'services');
  $r->get('/json/state/:provider/:host/:service')->to(controller => 'json', action => 'state');

  # Config Routing
  $r->get('/config')->to(controller => 'config', action => 'config');
  $r->post('/config')->to(controller => 'config', action => 'configure');
}

1;
