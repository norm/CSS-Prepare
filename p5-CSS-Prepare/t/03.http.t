use Modern::Perl;
use Test::More;

use CSS::Prepare;
use Data::Dumper;
local $Data::Dumper::Terse     = 1;
local $Data::Dumper::Indent    = 1;
local $Data::Dumper::Useqq     = 1;
local $Data::Dumper::Deparse   = 1;
local $Data::Dumper::Quotekeys = 0;
local $Data::Dumper::Sortkeys  = 1;

if ( $ENV{'OFFLINE'} ) {
    plan skip_all => 'Not online.';
    exit;
}
plan tests => 2;


my $preparer = CSS::Prepare->new();
my $base_url = 'http://tests.cssprepare.com/';
my( @structure, @parsed );

if ( ! $preparer->has_http() ) {
    ok( 1 == 0, 'HTTP::Lite or LWP::UserAgent not found' );
}


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

    @parsed = $preparer->parse_url( "${base_url}/basic.css" );
    is_deeply( \@structure, \@parsed )
        or say "'${base_url}/css/basic.css' was:\n" . Dumper \@parsed;
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
    
    $preparer->set_base_url( $base_url );
    my $url = "/site/subsite/basic.css";
    @parsed = $preparer->parse_url_structure( $url );
    is_deeply( \@structure, \@parsed )
        or say "'${url}' was:\n" . Dumper \@parsed;
}
