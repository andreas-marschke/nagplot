#!/usr/bin/perl

=head1 NAME

Nagplot::Core::Source::Nagios - Nagios Source

=head1 DESCRIPTION

The Nagios Source is basically a webscraper for Nagios. Performance data per service is taken as metric data for
generating states. Services and hosts in Nagios are determined by
http://nagiosdomain.tld/your/path/to/nagios/cgi-bin/config.cgi?type=hosts and /config.cgi?type=services.

=head2 COMPATIBILITY

This source is compatible with Nagios versions
  2.x
  3.x
Icinga Classic Versions:
  1.x

=cut

package Nagplot::Core::Source::Nagios;

our $VERSION = '';

use 5.010_000;

use Moose;
use Mojo::UserAgent;
use HTML::TableExtract;
use Data::Dumper;
use DateTime;
use URI;
use Carp;
use DateTime::Format::Strptime;
use Nagplot::Core::Types::Host;
use Nagplot::Core::Types::Service;
use Nagplot::Core::Types::State;
use Nagplot::Core::Types::Error;

extends 'Nagplot::Core::Source::Meta';

=head1 CONFIGURATION

The Nagios DataSource handles the communication of nagplot with Nagios hosts. This datasource will
crawl the webpages of Nagios if it is a seperate host. Therefore it is important to know for the datasource
where the webinterface is located and how to talk to it.

=head2 host

The IP or hostname of your hosted nagios instance

=cut
has 'host' => ( is => 'rw' , isa => 'Str', default => '127.0.0.1', required => 0 );

=head2 cgi_path

This is the path to your nagios cgi-bin files. This is usually the path after
the host or what you usually have configured in your webserver configuration.

=cut
has 'cgi_path' => ( is => 'rw', isa => 'Str', default => '/nagios/cgi-bin', required => 0 );

=head2 nagios_path

The path to your Nagios main websites

=cut
has 'nagios_path' => ( is => 'rw', isa => 'Str', default => '/nagios', required => 0);


=head2 user,pass

The username and password we are supposed to use if we want to authenticate with nagios

I<Leave both blank if you do not use the http-basic-authentication>

=cut
has 'user' => ( is => 'rw', isa => 'Str', default => 'nagplot', required => 0 );
has 'pass' => ( is => 'rw', isa => 'Str', default => 'nagplot', required => 0 );

=head2 date_format

The B<date_format> used by Nagios. See I<nagios.cfg> for more information.

=cut
has 'date_format' => ( is => 'rw', isa => 'Str', default => '%m-%d-$Y %Y:%M:%S', required => 0);

=head2 secure

If you use https set this to 1 or if you do B<not> use https set this to 0.

=cut
has 'secure' => ( is => 'rw', isa => 'Str', default => 1, required => 0);

sub BUILD {
  my $self = shift;
  my %params  = %{$self->config};
  $self->host($params{host})                       unless not defined $params{host};
  $self->cgi_path($params{cgi_path})               unless not defined $params{cgi_path};
  $self->nagios_path($params{nagios_path})         unless not defined $params{nagios_patoh};
  $self->user($params{user})                       unless not defined $params{user};
  $self->pass($params{pass})                       unless not defined $params{pass};
  $self->date_format($params{date_format})         unless not defined $params{date_format};
  $self->secure($params{secure})                   unless not defined $params{secure};
}

sub hosts {
  my $self = shift;
  my $ua = Mojo::UserAgent->new;
  my $url = $self->build_url();
  $url .= "/config.cgi?type=hosts";
  my $res = $ua->get($url)->res;
  if (defined $res->error) {
    return
      Nagplot::Core::Types::Error->new(
	provider => $self->name,
	response => 'ConnectionFailed',
	message => 'Connection the host: '.$self->host." could not be established",
	metadata => {
	  error => $res->error
	 });
  }

  my $div = $res->dom->at('.data');
  if (not defined $div) {
    return Nagplot::Core::Types::Error->new(
      provider => $self->name,
      response => 'DOMParseFailed',
      message => 'Response form the server at URL: '
	.$url." did not contain expected content");
  }

  my $content = $div->to_xml();
  my $te = HTML::TableExtract->new();
  $te->parse($content);
  my @rows;
  foreach my $ts ( $te->tables ) {
    foreach my $row ( $ts->rows ) {
      push @rows, $row;
    }
  }
  shift @rows; # first row is the header
  my @hosts;
  foreach (@rows) {
    chomp($_->[3]);
    push @hosts, Nagplot::Core::Types::Host->new(
      metadata => { description => $_->[1],
		    parent => $_->[3]
		  },
      ip => $_->[2],
      name => $_->[0],
      provider => $self->name,
      services => []
     );

  }
  return @hosts;
}

sub services {
  my $self = shift;
  my $host = shift;
  my $ua = Mojo::UserAgent->new;
  my $url = $self->build_url();
  $url .= "/config.cgi?type=services";
  my $res = $ua->get($url)->res;
  if (defined $res->error) {
    return
      Nagplot::Core::Types::Error->new(
	provider => $self->name,
	response => 'ConnectionFailed',
	message => 'Connection the host: '.$self->host." could not be established",
	metadata => {
	  error => $res->error
	 });
  }

  my $div = $res->dom->at('.data');
  if (not defined $div) {
    return Nagplot::Core::Types::Error->new(
      provider => $self->name,
      response => 'DOMParseFailed',
      message => 'Response form the server at URL: '.$url." did not contain expected content");
  }

  my $content = $div->to_xml();
  my $te = HTML::TableExtract->new();
  $te->parse($content);
  my @rows;
  foreach my $ts ( $te->tables ) {
    foreach my $row ( $ts->rows ) {
      push @rows,$row;
    }
  }
  shift @rows;
  my @services;
  foreach (@rows) {
    next unless ($_->[0] eq $host);
    push @services,Nagplot::Core::Types::Service->new(
      provider => $self->name,
      metadata => { command => $_->[5] },
      name => $_->[1]
     );
  }
  return @services;
}

sub state {
  my $self = shift;
  my $host = shift;
  my $service = shift;
  my $url = $self->build_url();
  $url .= "/extinfo.cgi?type=2&host=".$host."&service=".$service;
  my $ua = Mojo::UserAgent->new;
  my $res = $ua->get($url)->res;
  if (defined $res->error) {
    return
      Nagplot::Core::Types::Error->new(
	provider => $self->name,
	response => 'ConnectionFailed',
	message => 'Connection the host: '.$self->host." could not be established",
	metadata => {
	  error => $res->error
	 });
  }

  my $state = $res->dom->at('.stateInfoTable1');
  if (not defined $state) {
    return Nagplot::Core::Types::Error->new(
      provider => $self->name,
      response => 'DOMParseFailed',
      message => 'Response form the server at URL: '.$url." did not contain expected content");
  }
  my $content = $state->to_xml();
  my $te = HTML::TableExtract->new();
  $te->parse($content);
  my (@perf_data,@last_check);
  foreach my $ts ( $te->tables ) {
    push @perf_data,$ts->rows->[2];
  }
  foreach my $ts ( $te->tables ) {
    push @last_check,$ts->rows->[4];
  }
  my $json = {x => '0', y => '0'};
  my $text = $perf_data[0][1];
  $json->{y} = $1 if ($text =~ m/=([0-9\.]+)/); 
  $json->{x} = DateTime->now->epoch();
  return Nagplot::Core::Types::State->new(data => $json);
}


sub build_url{
  my $self = shift;
  my $url;
  $url .= "https://" if $self->secure;
  $url .= "http://" if not $self->secure;
  $url .= $self->user.":".$self->pass."@" unless $self->user eq '';
  $url .= $self->host;
  $url .= "/".$self->cgi_path;
  return $url;
}
__PACKAGE__->meta->make_immutable;
no Moose;
1;






