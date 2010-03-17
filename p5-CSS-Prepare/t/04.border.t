use Modern::Perl;
use Test::More  tests => 15;

use CSS::Prepare;

my $preparer = CSS::Prepare->new();
my( $css, @structure, $output );


# # border-something shorthand properties are expanded
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'border-top-width'    => 'thin',
                    'border-right-width'  => 'thin',
                    'border-bottom-width' => 'thin',
                    'border-left-width'   => 'thin',
                },
            },
        );
    $css = <<CSS;
div{border-width:thin;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "background color value was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'border-top-color'    => 'red',
                    'border-right-color'  => 'white',
                    'border-bottom-color' => 'blue',
                    'border-left-color'   => 'white',
                },
            },
        );
    $css = <<CSS;
div{border-color:red white blue;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "three value border-color shorthand was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'border-top-style'    => 'none',
                    'border-right-style'  => 'dotted',
                    'border-bottom-style' => 'dashed',
                    'border-left-style'   => 'solid',
                },
            },
        );
    $css = <<CSS;
div{border-style:none dotted dashed solid;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "four value border-color shorthand was:\n" . $output;
}

# border shorthand property is expanded
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'border-top-width' => '1px',
                    'border-top-style' => 'solid',
                    'border-top-color' => 'black',
                },
            },
        );
    $css = <<CSS;
div{border-top:1px solid black;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "border-top shorthand was:\n" . $output;
}
{
    @structure = (
            {
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
    $css = <<CSS;
div{border:1px solid blue;}
CSS

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "border shorthand was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'important-border-top-width'    => '1px',
                    'important-border-top-style'    => 'solid',
                    'important-border-top-color'    => 'blue',
                    'important-border-right-width'  => '1px',
                    'important-border-right-style'  => 'solid',
                    'important-border-right-color'  => 'blue',
                    'important-border-bottom-width' => '1px',
                    'important-border-bottom-style' => 'solid',
                    'important-border-bottom-color' => 'blue',
                    'important-border-left-width'   => '1px',
                    'important-border-left-style'   => 'solid',
                    'important-border-left-color'   => 'blue',
                },
            },
        );
    $css = <<CSS;
div{border:1px solid blue !important;}
CSS

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "important border shorthand was:\n" . $output;
}

# missing values do not trigger a shorthand
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
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
    $css = <<CSS;
div{border-bottom:1px solid blue;border-left:1px solid blue;border-right:1px solid blue;}
CSS

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "border shorthand was:\n" . $output;
}

# multiple properties in one block are correctly overridden
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'border-top-width'    => '1px',
                    'border-top-style'    => 'solid',
                    'border-top-color'    => 'blue',
                    'border-right-width'  => '1px',
                    'border-right-style'  => 'solid',
                    'border-right-color'  => 'blue',
                    'border-bottom-color' => '',
                    'border-bottom-style' => 'none',
                    'border-bottom-width' => '',
                    'border-left-width'   => '1px',
                    'border-left-style'   => 'solid',
                    'border-left-color'   => 'blue',
                },
            },
        );
    $css = <<CSS;
div{border:1px solid blue;border-bottom:none;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "value overriding was:\n" . $output;
}

# TODO can we use this example from CSS 2.1 8.5.4 in some meaningful way?
# > blockquote {
# >   border: solid red;
# >   border-left: double;
# >   color: black;
# > }
# > In the above example, the color of the left border is black, while the
# > other borders are red. This is due to 'border-left' setting the width,
# > style, and color. Since the color value is not given by the 'border-left'
# > property, it will be taken from the 'color' property. The fact that the
# > 'color' property is set after the 'border-left' property is not relevant.

# shorthands with empty values work
{
    @structure = (
            {
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
    $css = <<CSS;
div{border:blue;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "border shorthand color was:\n" . $output;
}
{
    @structure = (
            {
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
    $css = <<CSS;
div{border:thick;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "border shorthand width was:\n" . $output;
}
{
    @structure = (
            {
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
    $css = <<CSS;
img{border:0;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "border zero width was:\n" . $output;
}
{
    @structure = (
            {
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
    $css = <<CSS;
div{border:dashed red;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "shorthand properties was:\n" . $output;
}

TODO: {
local $TODO = "Logic for collapsing borders quite complex.";

# complex interactions
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'border-top-color'    => 'red',
                    'border-top-style'    => 'dashed',
                    'border-top-width'    => '2px',
                    'border-right-color'  => 'red',
                    'border-right-style'  => 'dashed',
                    'border-right-width'  => '1px',
                    'border-bottom-color' => 'red',
                    'border-bottom-style' => 'dashed',
                    'border-bottom-width' => '2px',
                    'border-left-color'   => 'red',
                    'border-left-style'   => 'dashed',
                    'border-left-width'   => '2px',
                },
            },
        );
    $css = <<CSS;
div{border:2px dashed red;border-right-width:1px;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "complex override one property was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'border-top-color'    => 'red',
                    'border-top-style'    => 'dashed',
                    'border-top-width'    => '2px',
                    'border-right-color'  => 'red',
                    'border-right-style'  => 'dashed',
                    'border-right-width'  => '1px',
                    'border-bottom-color' => 'red',
                    'border-bottom-style' => 'dashed',
                    'border-bottom-width' => '2px',
                    'border-left-color'   => 'red',
                    'border-left-style'   => 'dashed',
                    'border-left-width'   => '1px',
                },
            },
        );
    $css = <<CSS;
div{border:2px dashed red;border-width:2px 1px;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "complex override two properties was:\n" . $output;
}
}

# important values do not cause collapsing
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'important-border-top-color'    => 'blue',
                    'important-border-top-style'    => '',
                    'important-border-top-width'    => '',
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
    $css = <<CSS;
div{border-bottom:blue;border-left:blue;border-right:blue;border-top:blue !important;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "border shorthand color was:\n" . $output;
}

