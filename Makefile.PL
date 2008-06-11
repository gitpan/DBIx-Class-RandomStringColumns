use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'DBIx::Class::RandomStringColumns',
    AUTHOR              => 'Kan Fushihara <kan __at__ mobilefactory.jp>',
    VERSION_FROM        => 'lib/DBIx/Class/RandomStringColumns.pm',
    ABSTRACT_FROM       => 'lib/DBIx/Class/RandomStringColumns.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
        'String::Random' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'DBIx-Class-RandomStringColumns-*' },
);
