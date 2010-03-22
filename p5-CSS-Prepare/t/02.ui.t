use Modern::Perl;
use Test::More  tests => 9;

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



# cursors
{
    $css = <<CSS;
        a { cursor: url(blah.gif) crosshair; }
CSS
    @structure = (
            {
                original  => ' cursor: url(blah.gif) crosshair; ',
                errors    => [],
                selectors => [ 'a' ],
                block     => {
                    'cursor' => 'url(blah.gif) crosshair',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "cursor was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        a { cursor: pointer crosshair; }
CSS
    @structure = (
            {
                original  => ' cursor: pointer crosshair; ',
                errors    => [
                    {
                        error => 'invalid cursor property: '
                                 . q('pointer crosshair'),
                    },
                ],
                selectors => [ 'a' ],
                block     => {},
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "cursor error was:\n" . Dumper \@parsed;
}

# outline-something properties
{
    $css = <<CSS;
        div { outline-width: thin; }
CSS
    @structure = (
            {
                original  => ' outline-width: thin; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'outline-width' => 'thin',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "outline-width was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { outline-style: dotted; }
CSS
    @structure = (
            {
                original  => ' outline-style: dotted; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'outline-style' => 'dotted',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "outline-style was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { outline-color: red; }
CSS
    @structure = (
            {
                original  => ' outline-color: red; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'outline-color' => 'red',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "outline-width was:\n" . Dumper \@parsed;
}

# outline shorthand property is expanded
{
    $css = <<CSS;
        div { outline: 1px solid blue; }
CSS
    @structure = (
            {
                original  => ' outline: 1px solid blue; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'outline-width'    => '1px',
                    'outline-style'    => 'solid',
                    'outline-color'    => 'blue',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "outline shorthand was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { outline: blue 1px solid; }
CSS
    @structure = (
            {
                original  => ' outline: blue 1px solid; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'outline-width'    => '1px',
                    'outline-style'    => 'solid',
                    'outline-color'    => 'blue',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "outline shorthand different order was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { outline: 2px dashed; }
CSS
    @structure = (
            {
                original  => ' outline: 2px dashed; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'outline-width'    => '2px',
                    'outline-style'    => 'dashed',
                    'outline-color'    => '',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "outline shorthand missing value was:\n" . Dumper \@parsed;
}

# important
{
    $css = <<CSS;
        div { outline: 2px dashed !important; }
CSS
    @structure = (
            {
                original  => ' outline: 2px dashed !important; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'important-outline-width'    => '2px',
                    'important-outline-style'    => 'dashed',
                    'important-outline-color'    => '',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "important outline shorthand missing value was:\n"
               . Dumper \@parsed;
}
