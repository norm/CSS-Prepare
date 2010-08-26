use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'CSS::Prepare',
    AUTHOR              => 'Mark Norman Francis <norm@cackhanded.net>',
    VERSION_FROM        => 'lib/CSS/Prepare.pm',
    ABSTRACT_FROM       => 'lib/CSS/Prepare.pm',
    PL_FILES            => {},
    EXE_FILES           => [ 'bin/cssprepare' ],
    PREREQ_PM => {
        'Test::More'   => 0,
        'Modern::Perl' => 0,
        'version'      => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'CSS-Prepare-*' },
);
