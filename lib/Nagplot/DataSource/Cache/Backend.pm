#!/usr/bin/perl

=head1 NAME

Nagplot::DataSource::Cache::Backend - Manage caching of states, hosts and services

=head1 SYNOPSIS

 use Nagplot::DataSource::Cache::Backend;

 my $backend = Nagplot::DataSource::Cache::Backend->new(type);

=head1 DESCRIPTION


=cut

package Nagplot::DataSource::Cache::Backend;

our $VERSION = '';

use 5.010_000;

use strict;
use warnings;
use Moose;
use Module::Pluggable::Object search_path => ['Nagplot::DataSource::Cache::Backend'];


has 'data' => ( is => 'rw' , isa => 'Str');
has 'config' => ( is => 'rw' , isa => 'Str');
has 'type' => ( is => 'rw' , isa => 'Str' , required => 1);

=head1 store

Store bit of data

=cut

sub store {
  my $self = shift;
  
}

no Moose;
1;
