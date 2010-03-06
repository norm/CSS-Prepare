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


# shorthand margin properties are expanded
{
    $css = <<CSS;
        div { margin: 5px; }
CSS
    @structure = (
            {
                selector => [ 'div' ],
                block => {
                    'margin-top'    => '5px',
                    'margin-right'  => '5px',
                    'margin-bottom' => '5px',
                    'margin-left'   => '5px',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "one value margin shorthand was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { margin: 5px 2px; }
CSS
    @structure = (
            {
                selector => [ 'div' ],
                block => {
                    'margin-top'    => '5px',
                    'margin-right'  => '2px',
                    'margin-bottom' => '5px',
                    'margin-left'   => '2px',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "two value margin shorthand was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { margin: 5px 2px 0; }
CSS
    @structure = (
            {
                selector => [ 'div' ],
                block => {
                    'margin-top'    => '5px',
                    'margin-right'  => '2px',
                    'margin-bottom' => '0',
                    'margin-left'   => '2px',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "three value margin shorthand was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { margin: 5px 2px 0 4px; }
CSS
    @structure = (
            {
                selector => [ 'div' ],
                block => {
                    'margin-top'    => '5px',
                    'margin-right'  => '2px',
                    'margin-bottom' => '0',
                    'margin-left'   => '4px',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "four value margin shorthand was:\n" . Dumper \@parsed;
}

# multiple properties in one block are correctly overridden
{
    $css = <<CSS;
        div { 
            margin: 5px;
            margin-bottom: 0;
        }
CSS
    @structure = (
            {
                selector => [ 'div' ],
                block => {
                    'margin-top'    => '5px',
                    'margin-right'  => '5px',
                    'margin-bottom' => '0',
                    'margin-left'   => '5px',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "value overriding was:\n" . Dumper \@parsed;
}
