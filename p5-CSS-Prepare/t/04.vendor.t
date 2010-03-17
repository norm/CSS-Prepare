use Modern::Perl;
use Test::More  tests => 3;

use CSS::Prepare;

my $preparer = CSS::Prepare->new();
my( $css, @structure, $output );


# vendor extensions are preserved
{
    $css = <<CSS;
div{-moz-background-clip:-moz-initial;}
CSS
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { '-moz-background-clip' => '-moz-initial', },
            },
        );

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "-moz-background-clip value was:\n" . $output;
}
{
    $css = <<CSS;
div{-webkit-border-radius:6px;}
CSS
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { '-webkit-border-radius' => '6px', },
            },
        );

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "-webkit-border-raduis was:\n" . $output;
}
{
    $css = <<CSS;
div{-webkit-border-radius:6px !important;}
CSS
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'important--webkit-border-radius' => '6px', },
            },
        );

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "important -webkit-border-radius was:\n" . $output;
}
