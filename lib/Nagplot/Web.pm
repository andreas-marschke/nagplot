package Nagplot::Web;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub dashboard {
  my $self = shift;
  $self->render();
}

sub designer {
  my $self = shift;
  $self->render();
}

1;
