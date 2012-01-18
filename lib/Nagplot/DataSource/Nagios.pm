#!/usr/bin/perl

=head1 NAME

Nagplot::DataSource::Nagios - Nagios Backend for Nagplot::DataSource

=head1 DESCRIPTION

=cut

package Nagplot::DataSource::Nagios;

our $VERSION = '';

use 5.010_000;

use strict;
use warnings;
use Moose;
use Mojo::UserAgent;
use HTML::TableExtract;

has 'config' => ( is => 'rw' , isa => 'Ref', required => 1);

has 'host' => ( is => 'rw' , isa => 'Str', default => '127.0.0.1', required => 0 );
has 'cgi_path' => ( is => 'rw', isa => 'Str', default => '/nagios/cgi-bin', required => 0 );
has 'nagios_path' => ( is => 'rw', isa => 'Str', default => '/nagios', required => 0);
has 'pnp4nagios_path' => ( is => 'rw', isa => 'Str', default => '/pnp4nagios',required => 0 );
has 'user' => ( is => 'rw', isa => 'Str', default => 'nagplot', required => 0 );
has 'pass' => ( is => 'rw', isa => 'Str', default => 'nagplot', required => 0 );
has 'secure' => ( is => 'rw', isa => 'Str', default => 1, required => 0);

sub BUILD {
  my $self = shift;
  my %params  = %{$self->config->{Nagios}};
  $self->host($params{host})                       unless not defined $params{host};
  $self->cgi_path($params{cgi_path})               unless not defined $params{cgi_path};
  $self->nagios_path($params{nagios_path})         unless not defined $params{nagios_path};
  $self->pnp4nagios_path($params{pnp4nagios_path}) unless not defined $params{pnp4nagios_path};
  $self->user($params{user})                       unless not defined $params{user};
  $self->pass($params{pass})                       unless not defined $params{pass};
  $self->secure($params{secure})                   unless not defined $params{secure};
}

sub hosts { 
  my $self = shift;
  my $ua = Mojo::UserAgent->new;
  my $url = $self->build_url();
  $url .= "/config.cgi?type=hosts";
  my $div = $ua->get($url)->res->dom->at('.data');
  my $content = $div->to_xml();
  my $te = HTML::TableExtract->new();
  $te->parse($content);
  my @hosts;
  foreach my $ts ( $te->tables ) {
    foreach my $row ( $ts->rows ) {
      push @hosts,$row->[1];
    }
  }
  shift @hosts;
  return @hosts;
}

sub services {
  my $self = shift;
  my $host = shift;
  my $ua = Mojo::UserAgent->new;
  my $url = $self->build_url();
  $url .= "/config.cgi?type=services&expand=".$host;
  my $div = $ua->get($url)->res->dom->at('.data');
  my $content = $div->to_xml();
  my $te = HTML::TableExtract->new();
  $te->parse($content);
  my @services;
  foreach my $ts ( $te->tables ) {
    foreach my $row ( $ts->rows ) {
      push @services,$row->[5];
    }
  }
  @services = grep m/^check_/, @services;
  return @services;
}

sub query_state {
  my $self = shift;
}

sub build_url{
  my $self = shift;
  my $url;
  $url .= "https://" if $self->secure;
  $url .= "http://" if not $self->secure;
  $url .= $self->user.":".$self->pass."@";
  $url .= $self->host;
  $url .= "/".$self->cgi_path;
  return $url;
}

no Moose;
1;
