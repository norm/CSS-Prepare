use Modern::Perl;
use Test::More  tests => 6;

use CSS::Prepare;

my $preparer = CSS::Prepare->new();
my( $css, @structure, $output );


# shorthand padding properties are expanded
{
    @structure = (
            {
                selector => [ 'div' ],
                block => {
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

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "one value padding shorthand was:\n" . $output;
}
{
    @structure = (
            {
                selector => [ 'div' ],
                block => {
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

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "two value padding shorthand was:\n" . $output;
}
{
    @structure = (
            {
                selector => [ 'div' ],
                block => {
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

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "three value padding shorthand was:\n" . $output;
}
{
    @structure = (
            {
                selector => [ 'div' ],
                block => {
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

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "four value padding shorthand was:\n" . $output;
}

# multiple properties in one block are correctly overridden
{
    @structure = (
            {
                selector => [ 'div' ],
                block => {
                    'padding-top'    => '5px',
                    'padding-right'  => '5px',
                    'padding-bottom' => '0',
                    'padding-left'   => '5px',
                },
            },
        );
    $css = <<CSS;
div{padding:5px 5px 0;}
CSS

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "value overriding was:\n" . $output;
}

# less than four values doesn't give a shorthand
{
    @structure = (
            {
                selector => [ 'div' ],
                block => {
                    'padding-top'    => '5px',
                    'padding-right'  => '5px',
                    'padding-left'   => '5px',
                },
            },
        );
    $css = <<CSS;
div{padding-top:5px;padding-right:5px;padding-left:5px;}
CSS

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "value overriding was:\n" . $output;
}
