use Modern::Perl;
use Test::More  tests => 13;

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


# border-something shorthand properties are expanded
{
    $css = <<CSS;
        div { border-width: thin; }
CSS
    @structure = (
            {
                original  => ' border-width: thin; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'border-top-width'    => 'thin',
                    'border-right-width'  => 'thin',
                    'border-bottom-width' => 'thin',
                    'border-left-width'   => 'thin',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "one value border-width shorthand was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { border-width: 2px !important; }
CSS
    @structure = (
            {
                original  => ' border-width: 2px !important; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'important-border-top-width'    => '2px',
                    'important-border-right-width'  => '2px',
                    'important-border-bottom-width' => '2px',
                    'important-border-left-width'   => '2px',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "one value border-width shorthand was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { border-color: red white blue; }
CSS
    @structure = (
            {
                original  => ' border-color: red white blue; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'border-top-color'    => 'red',
                    'border-right-color'  => 'white',
                    'border-bottom-color' => 'blue',
                    'border-left-color'   => 'white',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "three value border-color shorthand was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { border-style: none dotted dashed solid; }
CSS
    @structure = (
            {
                original  => ' border-style: none dotted dashed solid; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'border-top-style'    => 'none',
                    'border-right-style'  => 'dotted',
                    'border-bottom-style' => 'dashed',
                    'border-left-style'   => 'solid',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "four value border-style shorthand was:\n" . Dumper \@parsed;
}

# border shorthand property is expanded
{
    $css = <<CSS;
        div { border-top: 1px solid black; }
CSS
    @structure = (
            {
                original  => ' border-top: 1px solid black; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'border-top-width' => '1px',
                    'border-top-style' => 'solid',
                    'border-top-color' => 'black',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "border-top shorthand was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { border: 1px solid blue; }
CSS
    @structure = (
            {
                original  => ' border: 1px solid blue; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'border-top-width'    => '1px',
                    'border-top-style'    => 'solid',
                    'border-top-color'    => 'blue',
                    'border-right-width'  => '1px',
                    'border-right-style'  => 'solid',
                    'border-right-color'  => 'blue',
                    'border-bottom-width' => '1px',
                    'border-bottom-style' => 'solid',
                    'border-bottom-color' => 'blue',
                    'border-left-width'   => '1px',
                    'border-left-style'   => 'solid',
                    'border-left-color'   => 'blue',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "border shorthand was:\n" . Dumper \@parsed;
}

# shorthands in different order work
{
    $css = <<CSS;
        div { border: blue 2px dashed; }
CSS
    @structure = (
            {
                original  => ' border: blue 2px dashed; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'border-top-width'    => '2px',
                    'border-top-style'    => 'dashed',
                    'border-top-color'    => 'blue',
                    'border-right-width'  => '2px',
                    'border-right-style'  => 'dashed',
                    'border-right-color'  => 'blue',
                    'border-bottom-width' => '2px',
                    'border-bottom-style' => 'dashed',
                    'border-bottom-color' => 'blue',
                    'border-left-width'   => '2px',
                    'border-left-style'   => 'dashed',
                    'border-left-color'   => 'blue',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "border shorthand different order was:\n" . Dumper \@parsed;
}

# multiple properties in one block are correctly overridden
{
    $css = <<CSS;
        div { 
            border: 1px solid blue; 
            border-bottom: none;
        }
CSS
    @structure = (
            {
                original  => ' 
            border: 1px solid blue; 
            border-bottom: none;
        ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'border-top-width'    => '1px',
                    'border-top-style'    => 'solid',
                    'border-top-color'    => 'blue',
                    'border-right-width'  => '1px',
                    'border-right-style'  => 'solid',
                    'border-right-color'  => 'blue',
                    # NOTE - actually, when the bottom border is reset
                    # by none, the initial value of border-bottom-color
                    # is "the value of the 'color' property" (CSS2.1 #8.5.2)
                    # and border-bottom-width is 'medium', but using a blank
                    # value captures the spirit of what the stylesheet is
                    # doing and allows proper results when output again
                    'border-bottom-color' => '',
                    'border-bottom-style' => 'none',
                    'border-bottom-width' => '',
                    'border-left-width'   => '1px',
                    'border-left-style'   => 'solid',
                    'border-left-color'   => 'blue',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "value overriding was:\n" . Dumper \@parsed;
}

# shorthands with missing values work
{
    $css = <<CSS;
        div { border: blue; }
CSS
    @structure = (
            {
                original  => ' border: blue; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'border-top-color'    => 'blue',
                    'border-top-style'    => '',
                    'border-top-width'    => '',
                    'border-right-color'  => 'blue',
                    'border-right-style'  => '',
                    'border-right-width'  => '',
                    'border-bottom-color' => 'blue',
                    'border-bottom-style' => '',
                    'border-bottom-width' => '',
                    'border-left-color'   => 'blue',
                    'border-left-style'   => '',
                    'border-left-width'   => '',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "value overriding was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { border: thick; }
CSS
    @structure = (
            {
                original  => ' border: thick; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'border-top-color'    => '',
                    'border-top-style'    => '',
                    'border-top-width'    => 'thick',
                    'border-right-color'  => '',
                    'border-right-style'  => '',
                    'border-right-width'  => 'thick',
                    'border-bottom-color' => '',
                    'border-bottom-style' => '',
                    'border-bottom-width' => 'thick',
                    'border-left-color'   => '',
                    'border-left-style'   => '',
                    'border-left-width'   => 'thick',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "value overriding was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        img { border: 0; }
CSS
    @structure = (
            {
                original  => ' border: 0; ',
                errors    => [],
                selectors => [ 'img' ],
                block     => {
                    'border-top-color'    => '',
                    'border-top-style'    => '',
                    'border-top-width'    => '0',
                    'border-right-color'  => '',
                    'border-right-style'  => '',
                    'border-right-width'  => '0',
                    'border-bottom-color' => '',
                    'border-bottom-style' => '',
                    'border-bottom-width' => '0',
                    'border-left-color'   => '',
                    'border-left-style'   => '',
                    'border-left-width'   => '0',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "border zero was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        fieldset { border: none; }
CSS
    @structure = (
            {
                original  => ' border: none; ',
                errors    => [],
                selectors => [ 'fieldset' ],
                block     => {
                    'border-top-color'    => '',
                    'border-top-style'    => 'none',
                    'border-top-width'    => '',
                    'border-right-color'  => '',
                    'border-right-style'  => 'none',
                    'border-right-width'  => '',
                    'border-bottom-color' => '',
                    'border-bottom-style' => 'none',
                    'border-bottom-width' => '',
                    'border-left-color'   => '',
                    'border-left-style'   => 'none',
                    'border-left-width'   => '',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "border none was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { border: dashed red; }
CSS
    @structure = (
            {
                original  => ' border: dashed red; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'border-top-color'    => 'red',
                    'border-top-style'    => 'dashed',
                    'border-top-width'    => '',
                    'border-right-color'  => 'red',
                    'border-right-style'  => 'dashed',
                    'border-right-width'  => '',
                    'border-bottom-color' => 'red',
                    'border-bottom-style' => 'dashed',
                    'border-bottom-width' => '',
                    'border-left-color'   => 'red',
                    'border-left-style'   => 'dashed',
                    'border-left-width'   => '',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "value overriding was:\n" . Dumper \@parsed;
}
