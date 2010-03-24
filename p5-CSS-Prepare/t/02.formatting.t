use Modern::Perl;
use Test::More  tests => 12;

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
        div { display: inline-block !important; }
CSS
    @structure = (
            {
                original  => ' display: inline-block !important; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'important-display' => 'inline-block', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "important display property was:\n" . Dumper \@parsed;
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
        or say "z-index property was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { direction: rtl; }
CSS
    @structure = (
            {
                original  => ' direction: rtl; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'direction' => 'rtl', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "direction property was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { unicode-bidi: embed; }
CSS
    @structure = (
            {
                original  => ' unicode-bidi: embed; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'unicode-bidi' => 'embed', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "unicode-bidi property was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { vertical-align: baseline; }
CSS
    @structure = (
            {
                original  => ' vertical-align: baseline; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'vertical-align' => 'baseline', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "vertical-align property was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { line-height: 1.3; }
CSS
    @structure = (
            {
                original  => ' line-height: 1.3; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'line-height' => '1.3', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "line-height property was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { width: 50%; min-width: 100px; max-width: 350px; }
CSS
    @structure = (
            {
                original  => ' width: 50%; min-width: 100px; max-width: 350px; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 
                    'width'     => '50%', 
                    'min-width' => '100px', 
                    'max-width' => '350px', 
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "width property was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { height: 50%; min-height: 100px; max-height: 350px; }
CSS
    @structure = (
            {
                original  => ' height: 50%; min-height: 100px; max-height: 350px; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 
                    'height'     => '50%', 
                    'min-height' => '100px', 
                    'max-height' => '350px', 
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "height property was:\n" . Dumper \@parsed;
}
