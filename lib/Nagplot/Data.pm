package Nagplot::Data;
use Data::Dumper;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub widgets {
  my $self = shift;
  my @widgets_config = $self->app->plugin(ConfigDir => [{ dir => $self->config->{Data}->{widgets} }]);

  my $widgets = $widgets_config[0];
  my $categories = {};

  foreach my $key (keys %$widgets) {
    my $widget = $widgets->{$key};
    $widget->{id} = lc $key;
    $categories->{$widget->{category}} = {}
      if not defined $categories->{$widget->{category}};

    $categories->{$widget->{category}}->{id} = lc $widget->{category};


    $categories->{$widget->{category}}->{elements} = []
      if not defined $categories->{$widget->{category}}->{elements};

    push $categories->{$widget->{category}}->{elements},$widget;
  }
  my @collection;

  foreach my $key (keys %$categories) {
    $categories->{$key}->{name} = $key;
    push @collection,$categories->{$key};
  }

  $self->render_json(\@collection);
}


sub layouts {
  my $self = shift;
  my @layouts_config = $self->app->plugin(ConfigDir => [{ dir => $self->config->{Data}->{layouts}}]);

  my $layouts = $layouts_config[0];

  my @keys = keys %$layouts;
  $self->app->log->debug(qq{Found layouts: @keys });

  my @collection;
  foreach my $key (keys %$layouts) {
    $layouts->{$key}->{name} = $key;
    $layouts->{$key}->{id} = lc $key;
    push @collection,$layouts->{$key};
  }

  $self->render_json(\@collection);
}

sub designs {
  my $self = shift;
  my @layouts_config = $self->app->plugin(ConfigDir => [{ dir => $self->config->{Data}->{designs}}]);

  my $layouts = $layouts_config[0];

  my @keys = keys %$layouts;
  $self->app->log->debug(qq{Found designs: @keys });

  my @collection;
  foreach my $key (keys %$layouts) {
    $layouts->{$key}->{name} = $key;
    $layouts->{$key}->{id} = lc $key;
    push @collection,$layouts->{$key};
  }

  $self->render_json(\@collection);
}


1;
