#!/usr/bin/perl

=head1 NAME

Nagplot::Core::Types::Host - Host type

=head1 SYNOPSIS

 use Nagplot::Core::Types::Host;
 my $object = Nagplot::Core::Types::Host->new(...);

=head1 DESCRIPTION

=cut

package Nagplot::Core::Types::Host;

our $VERSION = '0.1';

use 5.010_000;

use strict;
use warnings;
use Moose;

extends 'Nagplot::Core::Types::Meta';

has 'name' => ( is => 'rw' , isa => 'Str');
has 'ip' => ( is => 'rw' , isa => 'Str');

sub BUILD{
  my $self = shift;
  $self->type('Host');
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
