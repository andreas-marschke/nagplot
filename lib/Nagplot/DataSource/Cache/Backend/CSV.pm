#!/usr/bin/perl

=head1 NAME

Nagplot::DataSource::Cache::Backend::CSV - A backend for storing cache data in csv tables

=head1 SYNOPSIS

 {
  secret => 'nagplot',
  static_root => './public',
  DataSources => {
    enabled => ["Dummy"],
    cache => {
      Backend => 'CSV',
      BackendOpts => {
        StorageDir => './cache',
        extension => '.cache/r'
        encoding => 'utf8',
        eol => '\r\n',
        sep_char => ',',

      }
    }
  }
 };

=head1 DESCRIPTION

The CSV backend stores cached states in csv-format under StorageDir.
StorageDir can be an absolute path or relative to the nagplot root directory.

=cut

package Nagplot::DataSource::Cache::Backend::CSV;

our $VERSION = '';

use 5.010_000;

use strict;
use warnings;
use DBI;
use Moose;
use File::Slurp;

has 'storagedir' => ( is => 'rw' , isa => 'Str', default => './cache');
has 'extension' => ( is => 'rw' , isa => 'Str', default => '.cache/r');
has 'encoding' => ( is => 'rw' , isa => 'Str', default => 'utf8');
has 'eol' => (is => 'rw', isa => 'Str', default => '\r\n');
has 'sep_char' => ( is => 'rw' , isa => 'Str', default => ',');

has 'database' => ( is => 'rw' , isa => 'Object');
has 'sth_id_iter' => (is => 'rw' , isa => 'Object');
has 'sth_id_of' => (is => 'rw' , isa => 'Object');

sub BUILD {
  my $self = shift;

  $self->database( DBI->connect ("dbi:CSV:",undef, undef,
				 { f_dir        => $self->storagedir(),
				   f_ext        => $self->extension(),
				   f_encoding   => $self->encoding(),
				   csv_eol      => $self->eol(),
				   csv_sep_char => $self->sep_char(),
				   RaiseError   => 1,
				   PrintError   => 1,
				 }) or print "$DBI::errstr"
				);
}

=head1 store

store(data => {type => 'yourdata', source => 'somesource'});

Store stores data in an apropriate location/table.
parameters a hash containing:

=head2 source

  {
    type => 'source'
    source => 'sourcename'
  }

=head2 host

  {
   type => 'host',
   host => 'hostname',
   source => 'sourcename'
  }

=head2 service

  {
   type => 'service',
   host => 'hostname',
   service => 'servicename'
  }

=head2 checkstate

  {
   type => 'checkstate',
   host => 'hostname',
   service => 'servicename',
   state => '00'
  }

On Success returns 0;
If a bad hash was given it returns 1;

=cut

sub store {
  my $self = shift;
  my %data = shift;

  if ($data{type} eq 'sources') {
    my $sth = $self->database->prepare("INSERT INTO source (id, name) VALUES (?, ?);");
    my $new_id = $self->_get_iter($data{type});

    $sth->execute($new_id, $self->database->quote($data{source}));
    return $sth->finish;

  } elsif ($data{'type'} eq 'hosts') {
    my $sth = $self->database->prepare("INSERT INTO host (id, from_source, name) VALUES (?,?,?);");
    my $new_id = $self->_get_iter($data{type});
    my $source_id = $self->_get_id_of( $data{type}, $data{source});

    $sth->execute($new_id, $source_id, $self->database->quote($data{'host'}));
    return $sth->finish();

  } elsif ( $data{'type'} eq 'service' ) {
    my $sth = $self->database->prepare("INSERT INTO service (id, from_host, name) VALUES (?,?,?);");
    my $new_id = $self->_get_iter($data{type});
    my $host_id = $self->_get_id_of($data{host});

    $sth->execute($new_id,$host_id,$self->database->quote($data{name}));
    return $sth->finish;

  } elsif ($data{'type'} eq 'checkstate' ) {
    my $sth = $self->database->prepare("INSERT INTO checkstate (id, from_service, x, y) VALUES (?,?,?,?);");
    my $new_id = $self->_get_iter($data{type});
    my $service_id = $self->_get_id_of($data{service});

    $sth->execute($new_id,$service_id,$self->database->quote($data{x}),$self->database->quote($data{y}));
    return $sth->finish;

  } else {
    return 1;
  }
}

sub init {
  my ($self,$schema)  = @_;
  my $lines = read_file($schema);
  $self->database->do($lines) or die $self->database->errstr;

}

sub DEMOLISH {
  my $self = shift;
  $self->database->disconnect();
}

sub _get_iter {
  my $self = shift;
  my $table = shift;
  my $sth = $self->database->prepare("SELECT COUNT(id) FROM ?;");
  $sth->execute($table);
  return $self->sth_id_iter->fetchrow_hashref->{'id'}++;
}

sub _get_id_of {
  my ($self,$table,$name) = @_;
  my $sth = $self->database->prepare("SELECT id from ? where name like ?;");
  return $sth->fetch_hashref->{id};
}

no Moose;
1;
