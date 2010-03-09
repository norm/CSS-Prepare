use Modern::Perl;
use Test::More  tests => 2;

use CSS::Prepare;
use Data::Dumper;
local $Data::Dumper::Terse     = 1;
local $Data::Dumper::Indent    = 1;
local $Data::Dumper::Useqq     = 1;
local $Data::Dumper::Deparse   = 1;
local $Data::Dumper::Quotekeys = 0;
local $Data::Dumper::Sortkeys  = 1;

my $preparer = CSS::Prepare->new();
my( @structure, @parsed );


# can read in a file
{
    @structure = (
            {
                original  => '
    margin:  0px;
    padding: 0px;
',
                errors    => [],
                selectors => [ 'li', 'div' ],
                block     => {
                    'margin-top'     => '0px',
                    'margin-right'   => '0px',
                    'margin-bottom'  => '0px',
                    'margin-left'    => '0px',
                    'padding-top'    => '0px',
                    'padding-right'  => '0px',
                    'padding-bottom' => '0px',
                    'padding-left'   => '0px',
                },
            },
        );

    @parsed = $preparer->parse_file( 't/css/basic.css' );
    is_deeply( \@structure, \@parsed )
        or say "'t/css/basic.css' was:\n" . Dumper \@parsed;
}

# can read in a hierarchy of files
{
    @structure = (
            {
                original  => '
    margin:  0px;
    padding: 0px;
',
                errors    => [],
                selectors => [ 'li', 'div' ], 
                block     => {
                    'margin-top'     => '0px',
                    'margin-right'   => '0px',
                    'margin-bottom'  => '0px',
                    'margin-left'    => '0px',
                    'padding-top'    => '0px',
                    'padding-right'  => '0px',
                    'padding-bottom' => '0px',
                    'padding-left'   => '0px',
                },
            },
            {
                original  => '
    margin-top:         10px;
    margin-bottom:      10px;
',
                errors    => [],
                selectors => [ 'li' ],
                block     => {
                    'margin-top'     => '10px',
                    'margin-bottom'  => '10px',
                },
            },
        );
    
    $preparer->set_base_directory( 't/css' );
    @parsed = $preparer->parse_file_structure( '/site/subsite/basic.css' );
    is_deeply( \@structure, \@parsed )
        or say "'t/css/basic.css' was:\n" . Dumper \@parsed;
}
