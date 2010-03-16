use Modern::Perl;
use Test::More  tests => 2;

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
                original  => ' -moz-background-clip: -moz-initial; ',
                errors    => [],
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
                original  => ' -webkit-border-radius: 6px; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { '-webkit-border-radius' => '6px', },
            },
        );

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "-webkit-border-raduis was:\n" . $output;
}
