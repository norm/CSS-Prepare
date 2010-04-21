use Modern::Perl;
use Test::More  tests => 10;

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
{
    $css = <<CSS;
        div { background-position: left bottom; }
CSS
    @structure = (
            {
                original  => ' background-position: left bottom; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'background-position' => 'left bottom', },
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
                    'background-attachment' => '',
                    'background-color'      => '#000',
                    'background-image'      => 'url(blah.gif)',
                    'background-position'   => '',
                    'background-repeat'     => 'no-repeat',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "sparse background shorthand was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { background: #fff; }
CSS
    @structure = (
            {
                original  => ' background: #fff; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'background-attachment' => '',
                    'background-color'      => '#fff',
                    'background-image'      => '',
                    'background-position'   => '',
                    'background-repeat'     => '',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "almost empty background shorthand was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { background: #f8f8ff; }
CSS
    @structure = (
            {
                original  => ' background: #f8f8ff; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'background-attachment' => '',
                    'background-color'      => '#f8f8ff',
                    'background-image'      => '',
                    'background-position'   => '',
                    'background-repeat'     => '',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "six character hex colour shorthand was:\n" . Dumper \@parsed;
}

# regression tests
{
    $css = <<CSS;
        div { background:url(nav-footer.gif) left bottom no-repeat; }
CSS
    @structure = (
            {
                original  => ' background:url(nav-footer.gif) left bottom no-repeat; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'background-attachment' => '',
                    'background-color'      => '',
                    'background-image'      => 'url(nav-footer.gif)',
                    'background-position'   => 'left bottom',
                    'background-repeat'     => 'no-repeat',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "more shorthand was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
div { background: url(dot.png) no-repeat bottom left; }
CSS
    @structure = (
            {
                original  => ' background: url(dot.png) no-repeat bottom left; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'background-attachment' => '',
                    'background-color'      => '',
                    'background-image'      => 'url(dot.png)',
                    'background-position'   => 'bottom left',
                    'background-repeat'     => 'no-repeat',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "more shorthand was:\n" . Dumper \@parsed;
}