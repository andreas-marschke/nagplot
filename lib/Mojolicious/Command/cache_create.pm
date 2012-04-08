#!/usr/bin/perl

=head1 NAME

Mojolicious::Command::cache_create - create the caching for nagplot

=head1 SYNOPSIS

 ./nagplot create_cache

=head1 DESCRIPTION

This command will create the cache necessary for nagplot to store data. It works with the configuration
you have chosen in I<nagplot.conf>.

=cut

package Mojolicious::Command::cache_create;

our $VERSION = '';

use 5.010_000;

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long 'GetOptions';
use Mojo::Base 'Mojo::Command';
use Module::Pluggable::Object;

has description => "create the caching schema for your caching Backend.\n";
has usage => <<EOF;
usage: $0 cache_create [SCHEMA]

This is a nagplot specific deployment command. You should run it before running
nagplot. It will create the database schema for your caching backend see perldoc
Nagplot::DataSource::Cache::Backend for more information on this.

It takes a file that is a sql file (SCHEMA) and creates the database out of it.
But depending on your backend you can also leave this off. See perldoc
Nagplot::DataSource::Cache::Backend::YourBackend for reference.
EOF

sub run {
  my ($self,$schema_file) = @_;
  my $backend = $self->app->config->{DataSources}->{cache}->{Backend};
  my $opts = $self->app->config->{DataSources}->{cache}->{BackendOpts};
  my $finder = Module::Pluggable::Object->new(search_path => 'Nagplot::DataSource::Cache::Backend',
  					      instantiate => 'new',
  					      only => "Nagplot::DataSource::Cache::Backend::".$backend);

  die "ERROR: No such file or directory $schema_file" if (! -f $schema_file);

  print Dumper(%$opts);
  foreach ($finder->plugins(%$opts)) {
    $_->init($schema_file);
  }
}

1;

