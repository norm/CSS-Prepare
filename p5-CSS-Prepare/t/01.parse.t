use Modern::Perl;
use Test::More  tests => 7;

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


# basic declaration block
{
    $css = <<CSS;
        h1 { color: red; }
CSS
    @structure = (
            {
                original  => ' color: red; ',
                selectors => [ 'h1' ],
                errors    => [],
                block     => {
                    'color' => 'red',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "basic declaration was:\n" . Dumper \@parsed;
}

# basic declaration block with lots of whitespace
{
    $css = <<CSS;
        h1 { 
            color: 
                            red; 
        }
CSS
    @structure = (
            {
                original  => q( 
            color: 
                            red; 
        ),
                selectors => [ 'h1' ],
                errors    => [],
                block     => {
                    'color' => 'red',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "basic declaration with whitespace was:\n" . Dumper \@parsed;
}

# basic declaration block with comments
{
    $css = <<CSS;
        /* ignore me */
        h1 { 
        /* only one rule here
            background:     blue;
        */  
            color: 
                            red; 
        }
CSS
    @structure = (
            {
                original  => q( 
          
            color: 
                            red; 
        ),
                selectors => [ 'h1' ],
                errors    => [],
                block     => {
                    'color' => 'red',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "basic declaration with whitespace was:\n" . Dumper \@parsed;
}

# basic declaration block, no semi-colon on last value
{
    $css = <<CSS;
        h1 { color: red }
CSS
    @structure = (
            {
                original  => ' color: red ',
                selectors => [ 'h1' ],
                errors    => [],
                block     => {
                    'color' => 'red',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "basic stylesheet no semi-colon was:\n" . Dumper \@parsed;
}

# multiple declaration blocks
{
    $css = <<CSS;
        h1 { color: red; }
        #header { font-size: 13px; }
        p, li { margin-top: 5px; margin-bottom: 5px; }
CSS
    @structure = (
            {
                original  => q( color: red; ),
                selectors => [ 'h1' ],
                errors    => [],
                block     => {
                    'color' => 'red',
                },
            },
            {
                original  => q( font-size: 13px; ),
                selectors => [ '#header' ],
                errors    => [],
                block     => {
                    'font-size' => '13px',
                },
            },
            {
                original  => q( margin-top: 5px; margin-bottom: 5px; ),
                selectors => [ 'p', 'li' ],
                errors    => [],
                block     => {
                    'margin-top'    => '5px',
                    'margin-bottom' => '5px',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "basic stylesheet was:\n" . Dumper \@parsed;
}

# invalid properties are flagged
{
    $css = <<CSS;
        div { colur: #fff; }
CSS
    @structure = (
            {
                original  => ' colur: #fff; ',
                selectors => [ 'div' ],
                errors    => [
                    {
                        error => q(invalid property 'colur'),
                    },
                ],
                block     => {},
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "invalid property 'colur' was:\n" . Dumper \@parsed;
}

# CSS2.1 4.1.7:
# For example, since the "&" is not a valid token in a CSS 2.1 selector, a 
# CSS 2.1 user agent must ignore the whole second line, and not set the color
# of H3 to red:
{
    $css = <<CSS;
        h1, h2 {color: green }
        h3, h4 & h5 {color: red }
        h6 {color: black }
CSS
    @structure = (
            {
                original  => 'color: green ',
                selectors => [ 'h1', 'h2' ],
                errors    => [],
                block     => {
                    'color' => 'green',
                },
            },
            {
                original  => 'color: red ',
                selectors => [],
                errors    => [
                    {
                        error => 'ignored block -'
                               . ' unknown selector (CSS 2.1 #4.1.7)',
                    },
                ],
                block     => {},
            },
            {
                original  => 'color: black ',
                selectors => [ 'h6' ],
                errors    => [],
                block     => {
                    'color' => 'black',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "invalid selector was:\n" . Dumper \@parsed;
}

# TODO 
#   -   stylesheet with invalid syntax 
#   -   stylesheet with an @media block 
#   -   stylesheet with broken @media block
#   -   declaration block that includes a closing curly brace in there
#   -   other tests that find flaws in the simple regexps

# TODO - check CSS spec for behaviour on =>  errors and ignoring properties
#        and create more tests for those
