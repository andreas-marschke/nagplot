#!/usr/bin/perl

=head1 NAME

Nagplot::Source::Nagios - Nagios Backend for Nagplot::DataSource

=head1 SYNOPSIS

  DataSources => {
        Nagios => {
		# The ip or hostname your nagios is hosted
                host => '192.168.200.201',
		# The paths you chose to host your Nagios under (from a webrequest point of view)
                cgi_path => '/nagios/cgi-bin',
                nagios_path => '/nagios',
		# the username and password for the http-basic-authentication
                user => 'nagiosadmin',
                pass => 'nagiosadmin',
		# did you use a HTTP or HTTPS connection to your nagios instance?
                secure => 0,
        }
  }

=head1 DESCRIPTION

This plugin will allow you to query Nagios for performance data. See the documentation in this file
for which Options/Attributes you can set and which values they accept in your I<nagplot.conf>.

=cut

package Nagplot::Source::Nagios;

our $VERSION = '';

use 5.010_000;

use Moose;
use Mojo::UserAgent;
use HTML::TableExtract;
use Data::Dumper;
use DateTime::Format::Strptime;
use URI;


=head1 Non-Accessible Attributes

=head2 config

B<You cannot change this from nagplot.conf>

$config->{DataSource} of the config hash that is passed from nagplot.

=cut
has 'config' => ( is => 'rw' , isa => 'Ref', required => 1);

=head2 name 

The name the plugin authenticates as. It is important to find the correct part of the
nested config hash.

=cut
has 'name' => ( is => 'rw', isa => 'Str', default => 'Nagios');

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
  my %params  = %{$self->config->{$self->name}};
  $self->host($params{host})                       unless not defined $params{host};
  $self->cgi_path($params{cgi_path})               unless not defined $params{cgi_path};
  $self->nagios_path($params{nagios_path})         unless not defined $params{nagios_path};
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
  my $div = $ua->get($url)->res->dom->at('.data') or return "";
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
  my $div = $ua->get($url)->res->dom->at('.data') or return "";
  my $content = $div->to_xml();
  my $te = HTML::TableExtract->new();
  $te->parse($content);
  my @services;
  foreach my $ts ( $te->tables ) {
    foreach my $row ( $ts->rows ) {
      push @services,$row->[1];
    }
  }
  shift @services;
  @services = grep (!/^Description/, @services);
  
  return @services;
}

sub checkstate {
  my $self = shift;
  my $host = shift;
  my $service = shift;

  my $url = $self->build_url();
  $url .= "/extinfo.cgi?type=2&host=".$host."&service=".$service;
  my $ua = Mojo::UserAgent->new;
  my $state = $ua->get($url)->res->dom->at('.stateInfoTable1') or return "";
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
  $json->{x} = $self->parse_date($last_check[0][1]);
  return $json;
}

sub parse_date {
  my $self = shift;
  my $date_str = shift;
  my $date_format = $self->date_format;
  my $strp = new DateTime::Format::Strptime(pattern => $date_format,
				    	    on_error => 'croak');

  my $dt = $strp->parse_datetime($date_str);
  return -$dt->epoch;

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
