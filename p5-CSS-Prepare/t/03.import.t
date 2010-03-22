use Modern::Perl;
use Test::More  tests => 3;

use CSS::Prepare;
use Data::Dumper;
local $Data::Dumper::Terse     = 1;
local $Data::Dumper::Indent    = 1;
local $Data::Dumper::Useqq     = 1;
local $Data::Dumper::Deparse   = 1;
local $Data::Dumper::Quotekeys = 0;
local $Data::Dumper::Sortkeys  = 1;


my $preparer = CSS::Prepare->new();
my( $css, @structure, @parsed );



# @import is pulled in, and as a separate block
{
    @structure = (
            {
                type      => 'import',
                query     => undef,
                blocks    => [
                    {
                        original  => '
    color: green;
',
                        selectors => [ 'div' ],
                        errors    => [],
                        block     => {
                            'color' => 'green',
                        },
                    },
                ],
            },
            {
                type      => 'import',
                query     => undef,
                blocks    => [
                    {
                        original  => '
    color: blue;
',
                        selectors => [ 'div' ],
                        errors    => [],
                        block     => {
                            'color' => 'blue',
                        },
                    },
                ],
            },
            {
                type      => 'import',
                query     => 'print',
                blocks    => [
                    {
                        original  => '
    color: black;
',
                        selectors => [ 'div' ],
                        errors    => [],
                        block     => {
                            'color' => 'black',
                        },
                    },
                ],
            },
            {
                original  => '
    color: teal;
',
                selectors => [ 'div' ],
                errors    => [],
                block     => {
                    'color' => 'teal',
                },
            },
            {
                errors => [
                    {
                        error => '@import rule after statement(s) -- '
                                 . 'ignored (CSS 2.1 #4.1.5)',
                    },
                ],
            },
        );

    @parsed = $preparer->parse_file( 't/css/import.css' );
    is_deeply( \@structure, \@parsed )
        or say "multiple \@import was:\n" . Dumper \@parsed;
}

# @import does not work within an @media block (even though it is 'first')
{
    @structure = (
            {
                type      => 'import',
                query     => undef,
                blocks    => [
                    {
                        original  => '
    color: green;
',
                        selectors => [ 'div' ],
                        errors    => [],
                        block     => {
                            'color' => 'green',
                        },
                    },
                ],
            },
            {
                type      => 'at-media',
                query     => 'print',
                blocks    => [
                    {
                        errors => [
                            {
                                error => '@import rule after statement(s) -- '
                                         . 'ignored (CSS 2.1 #4.1.5)',
                            },
                        ],
                    },
                    {
                        original  => '
        color: black;
    ',
                        selectors => [ 'div' ],
                        errors    => [],
                        block     => {
                            'color' => 'black',
                        },
                    },
                ],
            },
        );

    @parsed = $preparer->parse_file( 't/css/broken-import.css' );
    is_deeply( \@structure, \@parsed )
        or say "\@import inside \@media was:\n" . Dumper \@parsed;
}

# @import with a media query
{
    @structure = (
            {
                type      => 'import',
                query     => 'print',
                blocks    => [
                    {
                        original  => '
    color: black;
',
                        selectors => [ 'div' ],
                        errors    => [],
                        block     => {
                            'color' => 'black',
                        },
                    },
                ],
            },
        );

    @parsed = $preparer->parse_file( 't/css/import-media.css' );
    is_deeply( \@structure, \@parsed )
        or say "\@import with media query was:\n" . Dumper \@parsed;
}
