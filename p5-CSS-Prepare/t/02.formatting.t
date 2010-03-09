use Modern::Perl;
use Test::More  tests => 5;

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


# individual properties work
{
    $css = <<CSS;
        div { display: none; }
CSS
    @structure = (
            {
                original  => ' display: none; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'display' => 'none', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "display property was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { 
            position: absolute; 
            top: 0;
            right: 2em;
            bottom: 10px;
            left: 10%;
        }
CSS
    @structure = (
            {
                original  => ' 
            position: absolute; 
            top: 0;
            right: 2em;
            bottom: 10px;
            left: 10%;
        ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 
                    'position' => 'absolute', 
                    'top'      => '0', 
                    'right'    => '2em', 
                    'bottom'   => '10px', 
                    'left'     => '10%', 
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "positioning was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { float: left; }
CSS
    @structure = (
            {
                original  => ' float: left; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'float' => 'left', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "display property was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { clear: both; }
CSS
    @structure = (
            {
                original  => ' clear: both; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'clear' => 'both', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "display property was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { z-index: 50; }
CSS
    @structure = (
            {
                original  => ' z-index: 50; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'z-index' => '50', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "display property was:\n" . Dumper \@parsed;
}
