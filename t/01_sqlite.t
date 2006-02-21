use strict;
use warnings;
use Test::More;
$| = 1;

BEGIN {
    eval "use DBD::SQLite";
    plan $@ ? (skip_all => 'needs DBD::SQLite for testing') : (tests => 7);
}

{
    package Foo;
    use base qw(DBIx::Class);
    use strict;
    use warnings;
    use DBIx::Class::RandomStringColumns;

    use File::Temp qw/tempfile/;
    my (undef, $DB) = tempfile();
    my @DSN = ("dbi:SQLite:dbname=$DB", '', '', { AutoCommit => 1 });

    END { unlink $DB if -e $DB }

    __PACKAGE__->load_components(qw/RandomStringColumns Core DB/);
    __PACKAGE__->connection(@DSN);
    __PACKAGE__->table('foo');
    __PACKAGE__->add_columns(qw(number rand_id rand_id2 session_id u_rand_id));
    __PACKAGE__->set_primary_key('session_id');
    __PACKAGE__->random_string_columns('u_rand_id');
    __PACKAGE__->random_string_columns('session_id', 'rand_id2');
    __PACKAGE__->random_string_columns('rand_id', {length => 3, solt => '[0-9]'});

    sub create_table {
        my $class = shift;
        $class->storage->dbh->do(q{
            CREATE TABLE foo (
                session_id VARCHAR(32) PRIMARY KEY,
                u_rand_id  VARCHAR(32),
                number     INT,
                rand_id    VARCHAR(32),
                rand_id2   VARCHAR(32)
            )
        });
    }
}

ok(Foo->create_table, 'create table');
ok(Foo->can('storage'), 'storage');
#is(Foo->__driver, "SQLite", "Driver set correctly");

my $foo = Foo->create({number => 3, u_rand_id => 'foo'});
is($foo->number, 3, 'can set number');
is($foo->u_rand_id, 'foo', 'no rewrite if set');
like($foo->session_id, qr/^[A-Za-z0-9]{32}$/, 'set random string column');
like($foo->rand_id,  qr/^[0-9]{3}$/, 'set random string column at rand_id');
like($foo->rand_id2, qr/^[A-Za-z0-9]{32}$/, 'set random string column at rand_id2');

