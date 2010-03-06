use Modern::Perl;
use Test::More  tests => 3;

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
                selector => [ 'h1' ],
                block => {
                    'color' => 'red',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "basic stylesheet was:\n" . Dumper \@parsed;
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
                selector => [ 'h1' ],
                block => {
                    'color' => 'red',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "basic stylesheet was:\n" . Dumper \@parsed;
}

# TODO - declaration block, no semi-colon on last value
# TODO - declaration block, invalid selector

# multiple declaration blocks
{
    $css = <<CSS;
        h1 { color: red; }
        #header { font-size: 13px; }
        p, li { margin-top: 5px; margin-bottom: 5px; }
CSS
    @structure = (
            {
                selector => [ 'h1' ],
                block => {
                    'color' => 'red',
                },
            },
            {
                selector => [ '#header' ],
                block => {
                    'font-size' => '13px',
                },
            },
            {
                selector => [ 'p', 'li' ],
                block => {
                    'margin-top'    => '5px',
                    'margin-bottom' => '5px',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "basic stylesheet was:\n" . Dumper \@parsed;
}

# TODO 
#   -   stylesheet with invalid syntax 
#   -   stylesheet with an @media block 
#   -   stylesheet with broken @media block
#   -   declaration block that includes a closing curly brace in there
#   -   other tests that find flaws in the simple regexps

# TODO - check CSS spec for behaviour on =>  errors and ignoring properties
#        and create more tests for those
