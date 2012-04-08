#!/usr/bin/perl

=head1 NAME

Nagplot::Source::Dummy - Dummy Backend for Nagplot::DataSource

=head1 SYNOPSIS

 config => {
   DataSources => {
     enabled => [Nagios, Dummy],
     Dummy => {}
   }
 }

=head1 DESCRIPTION

It will create random data to debug the frontend and examples.

=head1 CONFIGURATION

This datasource does not have any configuration options.
If you want to use it set an empty hash as the config value
in your nagplot.conf

 config => {
   DataSources => {
     enabled => [Nagios, Dummy],
     Dummy => {}
   }
 }

=cut

package Nagplot::Source::Dummy;

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
