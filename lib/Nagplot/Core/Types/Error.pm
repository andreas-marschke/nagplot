#!/usr/bin/perl

=head1 NAME

Nagplot::Core::Types::Error - Error type

=head1 SYNOPSIS

 use Nagplot::Core::Types::Error;
 my $object = Nagplot::Core::Types::Error->new(...);

=head1 DESCRIPTION

=cut

package Nagplot::Core::Types::Error;

our $VERSION = '0.1';

use 5.010_000;

use strict;
use warnings;
use Moose;

extends 'Nagplot::Core::Types::Meta';

has 'response' => ( is => 'rw' , isa => 'Str');
has 'message' => ( is => 'rw' , isa => 'Str');

sub BUILD{
  my $self = shift;
  $self->type('Error');
}
no Moose;
1;
