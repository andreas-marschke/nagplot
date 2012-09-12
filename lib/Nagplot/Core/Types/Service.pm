#!/usr/bin/perl

=head1 NAME

Nagplot::Core::Types::Service - Service type

=head1 SYNOPSIS

 use Nagplot::Core::Types::Service;
 my $object = Nagplot::Core::Types::Service->new(...);

=head1 DESCRIPTION

=cut

package Nagplot::Core::Types::Service;

our $VERSION = '0.1';

use 5.010_000;

use strict;
use warnings;
use Moose;

extends 'Nagplot::Core::Types::Meta';

sub BUILD{
  my $self = shift;
  $self->type('Service');
}

has 'name' => ( is => 'rw' , isa => 'Str');
has 'metric' => ( is => 'rw' , isa => 'Str', default => 'kB/s');
has 'color' => ( is => 'rw' , isa => 'Str');
has 'renderer' => ( is => 'rw' , isa => 'Str');

#has 'collection' => ( is => 'rw' , isa => 'ArrayRef[HashRef[Int]]');

no Moose;
1;


