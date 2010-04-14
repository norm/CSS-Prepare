use Modern::Perl;
use Test::More  tests => 14;

use CSS::Prepare;

my $preparer_concise = CSS::Prepare->new();
my $preparer_pretty  = CSS::Prepare->new( pretty => 1 );
my( $css, @structure, $output );


# shorthand padding properties are expanded
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'padding-top'    => '5px',
                    'padding-right'  => '5px',
                    'padding-bottom' => '5px',
                    'padding-left'   => '5px',
                },
            },
        );
    $css = <<CSS;
div{padding:5px;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "one value padding shorthand was:\n" . $output;
    $css = <<CSS;
div {
    padding:                5px;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "one value padding shorthand was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'important-padding-top'    => '5px',
                    'important-padding-right'  => '5px',
                    'important-padding-bottom' => '5px',
                    'important-padding-left'   => '5px',
                },
            },
        );
    $css = <<CSS;
div{padding:5px !important;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "one value padding shorthand was:\n" . $output;
    $css = <<CSS;
div {
    padding:                5px
                            !important;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "one value padding shorthand was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'padding-top'    => '5px',
                    'padding-right'  => '2px',
                    'padding-bottom' => '5px',
                    'padding-left'   => '2px',
                },
            },
        );
    $css = <<CSS;
div{padding:5px 2px;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "two value padding shorthand was:\n" . $output;
    $css = <<CSS;
div {
    padding:                5px 2px;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "two value padding shorthand was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'padding-top'    => '5px',
                    'padding-right'  => '2px',
                    'padding-bottom' => '0',
                    'padding-left'   => '2px',
                },
            },
        );
    $css = <<CSS;
div{padding:5px 2px 0;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "three value padding shorthand was:\n" . $output;
    $css = <<CSS;
div {
    padding:                5px 2px 0;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "three value padding shorthand was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'padding-top'    => '5px',
                    'padding-right'  => '2px',
                    'padding-bottom' => '0',
                    'padding-left'   => '4px',
                },
            },
        );
    $css = <<CSS;
div{padding:5px 2px 0 4px;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "four value padding shorthand was:\n" . $output;
    $css = <<CSS;
div {
    padding:                5px 2px 0 4px;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "four value padding shorthand was:\n" . $output;
}

# less than four values doesn't give a shorthand
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'padding-top'    => '5px',
                    'padding-right'  => '5px',
                    'padding-left'   => '5px',
                },
            },
        );
    $css = <<CSS;
div{padding-left:5px;padding-right:5px;padding-top:5px;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "value overriding was:\n" . $output;
    $css = <<CSS;
div {
    padding-left:           5px;
    padding-right:          5px;
    padding-top:            5px;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "value overriding was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'padding-top'    => '5px',
                    'important-padding-bottom' => '5px',
                    'padding-right'  => '5px',
                    'padding-left'   => '5px',
                },
            },
        );
    $css = <<CSS;
div{padding-bottom:5px !important;padding-left:5px;padding-right:5px;padding-top:5px;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "value overriding was:\n" . $output;
    $css = <<CSS;
div {
    padding-bottom:         5px
                            !important;
    padding-left:           5px;
    padding-right:          5px;
    padding-top:            5px;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "value overriding was:\n" . $output;
}
