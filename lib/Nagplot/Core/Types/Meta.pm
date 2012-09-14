#!/usr/bin/perl

=head1 NAME

Nagplot::Core::Types::Meta - Base Type 

=head1 SYNOPSIS

 use Nagplot::Core::Types::Meta;

 my $object = Nagplot::Core::Types::Meta->new(...);

=head1 DESCRIPTION

=cut

package Nagplot::Core::Types::Meta;

our $VERSION = '0.1';

use 5.010_000;

use strict;
use warnings;
use Moose;
use MooseX::Storage;

with Storage('format' => 'JSON');

has 'metadata' => ( is => 'rw' , isa => 'HashRef[Str]', required => 0);

=head2 type

Has to be overridden by subclasses inorder to distinguish them from other types upon usage in json replies

=cut
has 'type' => ( is => 'rw' , isa => 'Str', default => sub {
		  my $self = shift;
		  my @name = split(/::/,$self->meta->name);
		  return $name[-1];
		});
no Moose;
1;

