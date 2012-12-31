#!/usr/bin/perl

=head1 NAME

Nagplot::Core::Source::Nagios - Nagios Source

=head1 SYNOPSIS

      "Icinga Classic" => {
      Plugin => "Nagplot::Core::Source::Nagios",
      host => 'classic.demo.icinga.org',
      cgi_path => '/icinga/cgi-bin/',
      nagios_path => '',
      user => 'guest',
      pass => 'guest',
      secure => 0,
      date_format => '%m-%d-%Y %T'
     },


=head1 DESCRIPTION

This Source enables the use of the Icinga-Web REST API. Required for this to work you will need an Icinga version
higher or equal to 1.6 .

A I<prerequisite> for this Source to work is a working Icinga-Web configuration. Please refer to the Icinga
documentation for an explanation on how to enable this: http://docs.icinga.org/latest/en/icinga-web-api.html

=cut


package Nagplot::Core::Source::Icinga;

our $VERSION = '';

use 5.010_000;
use Moose;
use Mojo::UserAgent;
use Data::Dumper;
use Nagplot::Core::Types::Host;
use Nagplot::Core::Types::Service;
use Nagplot::Core::Types::State;
use Nagplot::Core::Types::Error;

extends 'Nagplot::Core::Source::Meta';

=head1 CONFIGURATION

Following are configuration options you can set in your nagplot.conf file:

=cut

=head2 host

The hostname or IP address which hosts your Icinga-Web instance

=cut

has 'host'     => ( is => 'rw', isa => 'Str');

=head2 api_path

The URI behind the hostname/ip address you defined in your 'host'. Using the default configuration
on Debian Icinga installations this would be: B</icinga-web/web/api>

=cut

has 'api_path' => ( is => 'rw', isa => 'Str');

=head2 user

The username for which you have authorized appkit.api.access to be available

=cut

has 'user'     => ( is => 'rw', isa => 'Str');

=head2 api_key

The API key you have generated in the Icinga-Web configuration

=cut

has 'api_key'  => ( is => 'rw', isa => 'Str');

=head2 secure

If you configured icinga-web to run over HTTPS set this to "1" otherwise set it to "0".

=cut

has 'secure'   => ( is => 'rw', isa => 'Str', default => 1);

=head2 protocol

Currently only json is supported.

=cut

has 'protocol' => ( is => 'rw', isa => 'Str');

sub BUILD {
  my $self = shift;
  my %params  = %{$self->config};
  $self->host($params{host})          unless not defined $params{host};
  $self->api_path($params{api_path})  unless not defined $params{api_path};
  $self->user($params{user})          unless not defined $params{user};
  $self->api_key($params{api_key})    unless not defined $params{api_key};
  $self->secure($params{secure})      unless not defined $params{secure};
  $self->protocol($params{protocol})  unless not defined $params{protocol};
}

sub hosts {
  my $self = shift;
  my @hosts;
  my $url = $self->buildurl('hosts');
  my $ua = Mojo::UserAgent->new;
  my $res = $ua->get($url)->res;
  if (defined $res->error) {
    return Nagplot::Core::Types::Error->new(
      provider => $self->name,
      response => 'ConnectionFailed',
      message => 'Connection the host: '.$self->host." could not be established",
      metadata => {
	error => $res->error
       });
  }
  my $json = $res->json;
  if (not defined $json->{result}) {
    if ($json->{success} eq 'false') {
      return Nagplot::Core::Types::Error->new(
	provider => $self->name,
	response => 'QueryError',
	message => @$json->{errors}[0]
       );
    }
  }

  foreach my $result ($json->{result}) {
    foreach my $host (@$result) {
      push @hosts,
	Nagplot::Core::Types::Host->new(provider => $self->name,
				       ip => $host->{HOST_ADDRESS},
				       name => $host->{HOST_NAME},
					metadata =>{
					 OID => $host->{HOST_OBJECT_ID},
					 instance => $host->{HOST_INSTANCE_ID},
					 name => $host->{HOST_DISPLAY_NAME},
					 ID => $host->{HOST_ID}
					}
				      );
    }
  }
  return @hosts;
}

sub services {
    my $self = shift;
    my $host = shift;
    my @services;
    my $url = $self->buildurl('services',$host);
    my $ua = Mojo::UserAgent->new;
    my $res = $ua->get($url)->res;
    if (defined $res->error) {
      return Nagplot::Core::Types::Error->new(
	provider => $self->name,
	response => 'ConnectionFailed',
	message => 'Connection the host: '.$self->host." could not be established",
	metadata => {
	  error => $res->error
	 });
    }
    my $json = $res->json;
    if (not defined $json->{result}) {
      $self->log()->info(Dumper($json));
      if ($json->{success} eq "false") {
	return Nagplot::Core::Types::Error->new(
	  provider => $self->name,
	  response => 'QueryError',
	  message => @$json->{errors}[0]
	 );
      }
    }

    foreach my $result ($json->{result}) {
      foreach my $service (@$result) {
	push @services,
	  Nagplot::Core::Types::Service->new( provider => $self->name,
					      metadata => {
						status_message => $service->{SERVICE_OUTPUT},
						ID => $service->{SERVICE_ID},
						OID => $service->{OBJECT_ID},
						active => $service->{SERVICE_IS_ACTIVE}
					       },
					      name =>  $service->{SERVICE_NAME}
					     );
      }
    }
    return @services;
}

sub state {
  my ($self,$host,$service) = @_;

  my %json;
  my $ua = Mojo::UserAgent->new;
  my $res = $ua->get($self->buildurl('state',$host,$service))->res;

  if (defined $res->error) {
    return Nagplot::Core::Types::Error->new(
      provider => $self->name,
      response => 'ConnectionFailed',
      message => 'Connection the host: '.$self->host." could not be established",
      metadata => {
	error => $res->error
       });
  }
  my $json = $res->json;
  if (not defined $json->{result}) {
    if ($json->{success} eq 'false') {
      return Nagplot::Core::Types::Error->new(
	provider => $self->name,
	response => 'QueryError',
	message => @$json->{errors}[0]
       );
    }
  }
  my $hash = ${$json->{result}}[0];
  my %data;
  foreach (split /;/,$hash->{SERVICE_PERFDATA}) {
    if (m/(.+)=([0-9\.]+)/) {
      $data{"$1"} = "$2";
    }
  }
  my $state = Nagplot::Core::Types::State->new(data => \%data);
  return $state;
}

sub buildurl {
  my $self = shift;
  my ($type,$host,$service) = @_;

  my $url = "";
  $self->secure eq 1 ?
    $url .= "https://" :
      $url .= "http://";
  $url .= $self->host() . $self->api_path . '/';

  if ($type eq "hosts") {
    $url .= "host";
  }
  elsif ($type eq "services") {
    return Nagplot::Core::Types::Error->new(response => "Failed",
					    message => "No Service Specified")
      if not defined $host;
    $url .= "service/filter[AND(HOST_NAME|=|".$host.")]";
  } elsif ($type eq "state") {
    return Nagplot::Core::Types::Error->new(response => "Failed",
					    message => "No Host Specified")
      if not defined $host;
    return Nagplot::Core::Types::Error->new(response => "Failed",
					    message => "No Service Specified")
      if not defined $service;
    $url .= "service/filter[AND(HOST_NAME|=|".$host.";SERVICE_NAME|=|".$service.")]";
  }
  $url .= '/authkey='.$self->api_key . '/' . $self->protocol;
  $self->log()->info($url);
  return $url;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
