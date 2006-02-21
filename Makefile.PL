use ExtUtils::MakeMaker;
WriteMakefile(
        'NAME'         => 'DBIx::Class::RandomStringColumns',
        'VERSION_FROM' => 'lib/DBIx/Class/RandomStringColumns.pm', # finds $VERSION
        'PREREQ_PM'    => {
                Test::More => 0.32,
        },
);
