use Modern::Perl;
use Test::More  tests => 3;

use CSS::Prepare;

use File::Temp;
use File::Copy;
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
                    'margin-top'     => '0',
                    'margin-right'   => '0',
                    'margin-bottom'  => '0',
                    'margin-left'    => '0',
                    'padding-top'    => '0',
                    'padding-right'  => '0',
                    'padding-bottom' => '0',
                    'padding-left'   => '0',
                },
            },
        );

    @parsed = $preparer->parse_file( 't/css/basic.css' );
    is_deeply( \@structure, \@parsed )
        or say "'t/css/basic.css' was:\n" . Dumper \@parsed;
}

# doesn't explode on an absolute filename
{
    my $temp_file = tmpnam();
    copy 't/css/basic.css', $temp_file;
    
    @parsed = $preparer->parse_stylesheet( $temp_file );
    is_deeply( \@structure, \@parsed )
        or say "'t/css/basic.css' absolute path was:\n" . Dumper \@parsed;
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
                    'margin-top'     => '0',
                    'margin-right'   => '0',
                    'margin-bottom'  => '0',
                    'margin-left'    => '0',
                    'padding-top'    => '0',
                    'padding-right'  => '0',
                    'padding-bottom' => '0',
                    'padding-left'   => '0',
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
