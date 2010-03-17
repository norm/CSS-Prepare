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
        div { background-color: #000; }
CSS
    @structure = (
            {
                original  => ' background-color: #000; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'background-color' => '#000', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "background color value was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { background-color: #000 !important; }
CSS
    @structure = (
            {
                original  => ' background-color: #000 !important; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'important-background-color' => '#000', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "background color value was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { background-position: top; }
CSS
    @structure = (
            {
                original  => ' background-position: top; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'background-position' => 'top', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "background-position was:\n" . Dumper \@parsed;
}

# shorthand works
{
    $css = <<CSS;
        div { background: #000 url(blah.gif) no-repeat fixed center center; }
CSS
    @structure = (
            {
                original  => ' background: #000 url(blah.gif)'
                           . ' no-repeat fixed center center; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'background-color'      => '#000', 
                    'background-image'      => 'url(blah.gif)', 
                    'background-repeat'     => 'no-repeat', 
                    'background-attachment' => 'fixed', 
                    'background-position'   => 'center center', 
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "full background shorthand was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { background: #000 url(blah.gif) no-repeat; }
CSS
    @structure = (
            {
                original  => ' background: #000 url(blah.gif) no-repeat; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'background-color'  => '#000', 
                    'background-image'  => 'url(blah.gif)', 
                    'background-repeat' => 'no-repeat', 
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "sparse background shorthand was:\n" . Dumper \@parsed;
}
