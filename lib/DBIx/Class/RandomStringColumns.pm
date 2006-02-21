package DBIx::Class::RandomStringColumns;

use strict;
use warnings;

our $VERSION = '0.02';

use base qw/DBIx::Class/;

use String::Random;

__PACKAGE__->mk_classdata( 'rs_auto_columns' => [] );
__PACKAGE__->mk_classdata( 'rs_length' => {} );
__PACKAGE__->mk_classdata( 'rs_salt' => {} );

=head1 NAME

DBIx::Class::RandomStringColumns - Implicit random string columns

=head1 SYNOPSIS

  pacakge Proj::Data;
  use base qw(DBIx::Class);
  __PACKAGE__->load_components(qw/RandomStringColumns Core DB/);

  package Proj::Data::Artist;
  use base qw(Proj::Data);
  __PACKAGE__->random_string_columns('rid', {length => 10});

=head1 DESCRIPTION

This L<DBIx::Class> component resembles the behaviour of
L<Class::DBI::Plugin::RandomStringColumn>, to make some columns implicitly created as random string.

Note that the component needs to be loaded before Core.

=head1 METHODS

=head2 random_string_columns

=cut

sub random_string_columns {
    my $self = shift;

    my $length = 32;
    my $salt   = '[A-Za-z0-9]';

    my $opt = pop @_;
    if (ref $opt ne 'HASH') {
        push @_, $opt;
    } else {
        $length = $opt->{length} || 32;
        $salt   = $opt->{salt  } || '[A-Za-z0-9]';
    }

    for (@_) {
        die "column $_ doesn't exist" unless $self->has_column($_);
        $self->rs_length->{$_} = $length;
        $self->rs_salt->{$_}   = $salt;
    }
    push @{$self->rs_auto_columns}, @_;
}

sub insert {
    my ($self) = @_;
    for my $column (@{$self->rs_auto_columns}) {

    $self->store_column( $column, $self->get_random_string($column) )
        unless defined $self->get_column( $column );
    }
    $self->next::method;
}

sub get_random_string {
    my $self   = shift;
    my $column = shift;

    my $val;
    do { # must be unique
        $val = String::Random->new->randregex(sprintf('%s{%d}', $self->rs_salt->{$column} , $self->rs_length->{$column}));
    } while ($self->search({$column => $val}));

    return $val;
}

=head1 AUTHORS

Kan Fushihara <kan at mobilefactory.jp>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
