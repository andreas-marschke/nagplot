#!/usr/bin/perl

=head1 NAME

Nagplot::Core::Types::State - State type

=head1 SYNOPSIS

 use Nagplot::Core::Types::State;
 my $object = Nagplot::Core::Types::State->new(...);

=head1 DESCRIPTION

=cut

package Nagplot::Core::Types::State;

our $VERSION = '0.1';

use 5.010_000;

use strict;
use warnings;
use Moose;

extends 'Nagplot::Core::Types::Meta';

sub BUILD{
  my $self = shift;
  $self->type('State');
}

has 'data' => ( is => 'rw' , isa => 'HashRef[Num]');

__PACKAGE__->meta->make_immutable;
no Moose;
1;
