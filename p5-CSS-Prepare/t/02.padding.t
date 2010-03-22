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


# shorthand padding properties are expanded
{
    $css = <<CSS;
        div { padding: 5px; }
CSS
    @structure = (
            {
                original  => ' padding: 5px; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'padding-top'    => '5px',
                    'padding-right'  => '5px',
                    'padding-bottom' => '5px',
                    'padding-left'   => '5px',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "one value padding shorthand was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { padding: 5px 2px; }
CSS
    @structure = (
            {
                original  => ' padding: 5px 2px; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'padding-top'    => '5px',
                    'padding-right'  => '2px',
                    'padding-bottom' => '5px',
                    'padding-left'   => '2px',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "two value padding shorthand was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { padding: 5px 2px 0; }
CSS
    @structure = (
            {
                original  => ' padding: 5px 2px 0; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'padding-top'    => '5px',
                    'padding-right'  => '2px',
                    'padding-bottom' => '0',
                    'padding-left'   => '2px',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "three value padding shorthand was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { padding: 5px 2px 0px 4px; }
CSS
    @structure = (
            {
                original  => ' padding: 5px 2px 0px 4px; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'padding-top'    => '5px',
                    'padding-right'  => '2px',
                    'padding-bottom' => '0',
                    'padding-left'   => '4px',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "four value padding shorthand was:\n" . Dumper \@parsed;
}

# important
{
    $css = <<CSS;
        div { padding: 5px 2px 0px 4px !important; }
CSS
    @structure = (
            {
                original  => ' padding: 5px 2px 0px 4px !important; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'important-padding-top'    => '5px',
                    'important-padding-right'  => '2px',
                    'important-padding-bottom' => '0',
                    'important-padding-left'   => '4px',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "important four value padding shorthand was:\n" . Dumper \@parsed;
}

# multiple properties in one block are correctly overridden
{
    $css = <<CSS;
        div { 
            padding: 5px;
            padding-bottom: 0em;
        }
CSS
    @structure = (
            {
                original  => ' 
            padding: 5px;
            padding-bottom: 0em;
        ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'padding-top'    => '5px',
                    'padding-right'  => '5px',
                    'padding-bottom' => '0',
                    'padding-left'   => '5px',
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
                padding-top: 5px;
                padding-right: 5px;
                padding-left: 5px;
            }
CSS
    @structure = (
            {
                original  => '
                padding-top: 5px;
                padding-right: 5px;
                padding-left: 5px;
            ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'padding-top'    => '5px',
                    'padding-right'  => '5px',
                    'padding-left'   => '5px',
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
        div { padding: 2 em; }
CSS
    @structure = (
            {
                original  => ' padding: 2 em; ',
                errors    => [
                    {
                        error => "invalid padding property: '2 em'"
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
