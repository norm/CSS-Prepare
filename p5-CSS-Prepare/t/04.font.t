use Modern::Perl;
use Test::More  tests => 3;

use CSS::Prepare;

my $preparer = CSS::Prepare->new();
my( $css, @structure, $output );


# individual properties work
{
    @structure = (
            {
                selector => [ 'div' ],
                block    => { 'font-size' => '13px', },
            },
        );
    $css = <<CSS;
div{font-size:13px;}
CSS

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "font size property was:\n" . $output;
}
{
    @structure = (
            {
                selector => [ 'div' ],
                block    => { 'font-style' => 'italic', },
            },
        );
     $css = <<CSS;
div{font-style:italic;}
CSS

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "font style property was:\n" . $output;
}

# shorthand works
{
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
    $css = <<CSS;
div{font:italic small-caps bold 13px/16px "Palatino";}
CSS

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "full font shorthand was:\n" . $output;
}
