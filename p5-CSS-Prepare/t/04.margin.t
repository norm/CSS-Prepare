use Modern::Perl;
use Test::More  tests => 6;

use CSS::Prepare;

my $preparer = CSS::Prepare->new();
my( $css, @structure, $output );


# shorthand margin properties are expanded
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'margin-top'    => '5px',
                    'margin-right'  => '5px',
                    'margin-bottom' => '5px',
                    'margin-left'   => '5px',
                },
            },
        );
    $css = <<CSS;
div{margin:5px;}
CSS

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "one value margin shorthand was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'margin-top'    => '5px',
                    'margin-right'  => '2px',
                    'margin-bottom' => '5px',
                    'margin-left'   => '2px',
                },
            },
        );
    $css = <<CSS;
div{margin:5px 2px;}
CSS

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "two value margin shorthand was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'margin-top'    => '5px',
                    'margin-right'  => '2px',
                    'margin-bottom' => '0',
                    'margin-left'   => '2px',
                },
            },
        );
    $css = <<CSS;
div{margin:5px 2px 0;}
CSS

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "three value margin shorthand was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'margin-top'    => '5px',
                    'margin-right'  => '2px',
                    'margin-bottom' => '0',
                    'margin-left'   => '4px',
                },
            },
        );
    $css = <<CSS;
div{margin:5px 2px 0 4px;}
CSS

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "four value margin shorthand was:\n" . $output;
}

# multiple properties in one block are correctly overridden
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'margin-top'    => '5px',
                    'margin-right'  => '5px',
                    'margin-bottom' => '0',
                    'margin-left'   => '5px',
                },
            },
        );
    $css = <<CSS;
div{margin:5px 5px 0;}
CSS

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "value overriding was:\n" . $output;
}

# less than four values doesn't give a shorthand
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'margin-top'    => '5px',
                    'margin-right'  => '5px',
                    'margin-left'   => '5px',
                },
            },
        );
    $css = <<CSS;
div{margin-top:5px;margin-right:5px;margin-left:5px;}
CSS

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "value overriding was:\n" . $output;
}
