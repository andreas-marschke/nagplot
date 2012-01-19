#!/usr/bin/perl

=head1 NAME

Nagplot::DataSource::Dummy - Dummy Backend for Nagplot::DataSource

=head1 DESCRIPTION

It will create random data to debug the frontend and examples;

=cut

package Nagplot::DataSource::Dummy;

our $VERSION = '';

use 5.010_000;

use strict;
use warnings;
use Moose;

has 'config' => ( is => 'rw' , isa => 'Ref', required => 1);

sub BUILD {
  my $self = shift;
}

sub hosts { 
  my $self = shift;
  return qw/localhost www mail ftp/;
}

sub services {
  my $self = shift;
  my $host = shift || "";
  if ( $host eq "localhost" ) {
	return qw/check_fs/;
  } elsif ( $host eq "www" ) {
	return qw/check_http/;
  } elsif ( $host eq "mail" ) {
	return qw/check_smtp/;
  } elsif ( $host eq "ftp" ) {
	return qw/check_ftp/;
  } else {
	return qw/check_ping/;
  }
}

sub query_state {
  my $self = shift;
  return rand(100);
}

no Moose;
1;
