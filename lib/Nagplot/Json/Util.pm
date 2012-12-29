#!/usr/bin/perl

=head1 NAME

Nagplot::Json::Util - Utility Class for sanatizing JSON output

=head1 SYNOPSIS

 use Nagplot::Json::Util;

 my $object = Nagplot::Json::Util->new();
 

=head1 DESCRIPTION

=cut

package Nagplot::Json::Util;

our $VERSION = '';

use 5.010_000;

use strict;
use warnings;
use Moose;
use JSON;

use Data::Dumper;

has 'json' => ( is => 'rw' , isa => 'JSON', default => sub {JSON->new->allow_nonref});

has 'log' => (is => 'rw', isa => 'Object', required => 1);

=head1 sanitize($obj)

Sanitize a Moose Object into JSON. Accepts a Moose Object which has MooseX::Storage defined

=cut

sub sanitize {
  my $self = shift;
  my $obj = shift;
  my $unfrozen = $self->json->decode($obj->freeze());
  if (defined $unfrozen->{services}) {
    foreach (@{$unfrozen->{services}}) {
      delete $_->{"__CLASS__"};
    }
  }
  delete $unfrozen->{"__CLASS__"};
  return $unfrozen;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
