package DBIx::Class::RandomStringColumns;
use strict;
use warnings;

our $VERSION = '0.04';

use base qw/DBIx::Class/;

use String::Random;

__PACKAGE__->mk_classdata( 'rs_auto_columns' => [] );
__PACKAGE__->mk_classdata( 'rs_length' => {} );
__PACKAGE__->mk_classdata( 'rs_solt' => {} );

sub random_string_columns {
    my $self = shift;

    my $length = 32;
    my $solt   = '[A-Za-z0-9]';

    my $opt = pop @_;
    if (ref $opt ne 'HASH') {
        push @_, $opt;
    } else {
        $length = $opt->{length} || 32;
        $solt   = $opt->{solt  } || '[A-Za-z0-9]';
    }

    for (@_) {
        die "column $_ doesn't exist" unless $self->has_column($_);
        $self->rs_length->{$_} = $length;
        $self->rs_solt->{$_}   = $solt;
    }
    push @{$self->rs_auto_columns}, @_;
}

sub insert {
    my $self = shift;
    for my $column (@{$self->rs_auto_columns}) {
        $self->store_column( $column, $self->get_random_string($column) )
            unless defined $self->get_column( $column );
    }
    $self->next::method(@_);
}

sub get_random_string {
    my $self   = shift;
    my $column = shift;

    my $rs = $self->result_source->schema->resultset($self->result_source->result_class);
    my $val;
    do { # must be unique
        $val = String::Random->new->randregex(sprintf('%s{%d}', $self->rs_solt->{$column} , $self->rs_length->{$column}));
    } while ($rs->search({$column => $val})->count);

    return $val;
}

1;

__END__
=head1 NAME

DBIx::Class::RandomStringColumns - Implicit random string columns

=head1 SYNOPSIS

  pacakge Artist;
  __PACKAGE__->load_components(qw/RandomStringColumns Core DB/);
  __PACKAGE__->random_string_columns('rid', {length => 10});

=head1 DESCRIPTION

This L<DBIx::Class> component resambles the behaviour of
L<Class::DBI::Plugin::RandomStringColumn>, to make some columns implicitly created as random string.

Note that the component needs to be loaded before Core.

=head1 METHODS

=head2 insert

=head2 random_string_columns

=head2 get_random_string

=head1 AUTHOR

Kan Fushihara  C<< <kan __at__ mobilefactory.jp> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2006, Kan Fushihara C<< <kan __at__ mobilefactory.jp> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

