#!/usr/bin/perl

=head1 NAME

Nagplot::Core::Source::Dummy - Dummy testing Source

=head1 SYNOPSIS

     "Dummy" => {
       Plugin => "Nagplot::Core::Source::Dummy",
       hosts => 4,
       services => 2
     }

=head1 DESCRIPTION


=cut

package Nagplot::Core::Source::Dummy;

our $VERSION = '';

use 5.010_000;
use Moose;
use DateTime;
use String::Random;
use Nagplot::Core::Types::Host;
use Nagplot::Core::Types::Service;
use Nagplot::Core::Types::State;

extends 'Nagplot::Core::Source::Meta';

=head2 hosts

Amount of hosts to generate randomly.

=cut

has 'host_num' => ( is => 'rw' , isa => 'Num', default => 10);

=head2 services

Amount of services to generate per host.

=cut

has 'service_num' => ( is => 'rw' , isa => 'Num', default => 5 );


sub BUILD {
  my $self = shift;
  my %params = %{$self->config};
  $self->hosts($params{host_num})       unless not defined $params{host_num};
  $self->services($params{service_num}) unless not defined $params{service_num};
}

sub hosts {
  my $self = shift;
  my @hosts;
  my $foo = new String::Random;
  my $domain =  $foo->randregex('[a-z0-9]{6}');
  my $tld =  $foo->randregex('[a-z]{3}');
  for (my $i = 0; $i < $self->host_num; $i++) {

    my $ip =join('.', (int(rand(255)),
		       int(rand(255)),
		       int(rand(255)),
		       int(rand(255))));

    my $hostname = $foo->randregex('[a-z0-9]{4}'); # Prints 3 random digits

    push @hosts,Nagplot::Core::Types::Host->new(
      services => [],
      metadata => { description => 'Marginally interesting data' },
      provider => $self->{name},
      ip => $ip,
      name => $hostname.".".$domain.".".$tld);
  }
  return @hosts;
}

sub services {
  my $self = shift;

  my @services;
  my @metrics = ('kB/s',
		 'MB/s',
		 'GB/s',
		 'TB/s',
		 'pkts/s',
		 'Ticks',
		 'load',
		 '% usage',
		 '% free',
		 'Meta',
		);
  my @color = ('red',
	       'yellow',
	       'blue',
	       'steelblue',
	       'green',
	       'grey',
	       'black');

  my $foo = new String::Random;

  for (my $i = 0; $i < $self->service_num; $i++) {
    my $check =  $foo->randregex('[a-z0-9]{6}');

    push @services,Nagplot::Core::Types::Service->new(
      provider => $self->name,
      metadata => { description => 'Marginally interesting data',
		    metric => $metrics[int(rand(9))]
		  },
      name => "check_".$check,
      color => $color[int(rand(6))]
     );
  }
  return @services;
}

sub state {
  my $self = shift;
  my $host = shift;
  my $service = shift;

  return Nagplot::Core::Types::State->new(
    data => {
      "$service" => int(rand(1000))
   });
}
__PACKAGE__->meta->make_immutable;
no Moose;
1;



