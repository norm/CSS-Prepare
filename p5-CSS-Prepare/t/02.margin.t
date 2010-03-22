use Modern::Perl;
use Test::More  tests => 8;

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
                original  => ' margin: 5px; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
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
                original  => ' margin: 5px 2px; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
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
        div { margin: 5px 2px 0px; }
CSS
    @structure = (
            {
                original  => ' margin: 5px 2px 0px; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
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
        div { margin: 5px 2px 0px 4px; }
CSS
    @structure = (
            {
                original  => ' margin: 5px 2px 0px 4px; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
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

# important
{
    $css = <<CSS;
        div { margin: 5px 2px 0px 4px !important; }
CSS
    @structure = (
            {
                original  => ' margin: 5px 2px 0px 4px !important; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'important-margin-top'    => '5px',
                    'important-margin-right'  => '2px',
                    'important-margin-bottom' => '0',
                    'important-margin-left'   => '4px',
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
            margin-bottom: 0em;
        }
CSS
    @structure = (
            {
                original  => ' 
            margin: 5px;
            margin-bottom: 0em;
        ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
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

# less than four values doesn't give a shorthand
{
        $css = <<CSS;
            div {
                margin-top: 5px;
                margin-right: 5px;
                margin-left: 5px;
            }
CSS
    @structure = (
            {
                original  => '
                margin-top: 5px;
                margin-right: 5px;
                margin-left: 5px;
            ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'margin-top'    => '5px',
                    'margin-right'  => '5px',
                    'margin-left'   => '5px',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "no shorthand was:\n" . Dumper \@parsed;
}

# invalid values are properly flagged
{
    $css = <<CSS;
        div { margin: 0 px; }
CSS
    @structure = (
            {
                original  => ' margin: 0 px; ',
                errors    => [
                    {
                        error => "invalid margin property: '0 px'"
                    },
                ],
                selectors => [ 'div' ],
                block     => {},
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "invalid value was:\n" . Dumper \@parsed;
}
