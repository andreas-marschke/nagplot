#!/usr/bin/perl

=head1 NAME

Nagplot::Core::Source::Meta - Meta Source other Sources extend

=head1 SYNOPSIS

 use Nagplot::Core::Source::Meta;

 my $object = Nagplot::Core::Source::Meta->new(...);

=head1 DESCRIPTION

=cut

package Nagplot::Core::Source::Meta;

our $VERSION = '0.1';

use 5.010_000;

use strict;
use warnings;
use Moose;

=head2 config

B<You cannot change this from nagplot.conf>

$config->{DataSource} of the config hash that is passed from nagplot.

=cut
has 'config' => ( is => 'rw' , isa => 'Ref', required => 1);

=head2 name 

The name the plugin authenticates as. It is important to find the correct part of the
nested config hash.

=cut
has 'name' => ( is => 'rw' , isa => 'Str', default => sub {
		  my $self = shift;
		  my @name = split(/::/,$self->meta->name);
		  return $name[-1];
		});

=head1 hosts

Get Information about the hosts

=cut

sub hosts {
  my $self = shift;

}

=head1 services

Get Information about the Services of a Host

=cut

sub services {
  my $self = shift;

}

=head1 state

Get the state of a service

=cut

sub state {
  my $self = shift;

}

=head1 configure

B<EXPERIMENTAL!>

Configure the Service

=cut

sub configure {
  my $self = shift;

}
__PACKAGE__->meta->make_immutable;
no Moose;
1;





