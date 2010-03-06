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


# individual properties work
{
    $css = <<CSS;
        div { font-size: 13px; }
CSS
    @structure = (
            {
                selector => [ 'div' ],
                block    => { 'font-size' => '13px', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "font size property was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { font-style: italic; }
CSS
    @structure = (
            {
                selector => [ 'div' ],
                block    => { 'font-style' => 'italic', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "font size property was:\n" . Dumper \@parsed;
}
 
# shorthand works
{
    $css = <<CSS;
        div { font: italic small-caps bold 13px/16px "Palatino"; }
CSS
    @structure = (
            {
                selector => [ 'div' ],
                block    => { 
                    'font-style'   => 'italic', 
                    'font-variant' => 'small-caps', 
                    'font-weight'  => 'bold', 
                    'font-size'    => '13px/16px', 
                    'font-family'  => '"Palatino"', 
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "full font shorthand was:\n" . Dumper \@parsed;
}
