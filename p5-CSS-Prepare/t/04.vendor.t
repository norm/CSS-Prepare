use Modern::Perl;
use Test::More  tests => 8;

use CSS::Prepare;

my $preparer_concise = CSS::Prepare->new();
my $preparer_pretty  = CSS::Prepare->new( pretty => 1 );
my( $css, @structure, $output );


# vendor extensions are preserved
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { '-moz-background-clip' => '-moz-initial', },
            },
        );
    $css = <<CSS;
div{-moz-background-clip:-moz-initial;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "-moz-background-clip value was:\n" . $output;
    
    $css = <<CSS;
div {
    -moz-background-clip:   -moz-initial;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "-moz-background-clip value was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { '-webkit-border-radius' => '6px', },
            },
        );
    $css = <<CSS;
div{-webkit-border-radius:6px;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "-webkit-border-raduis was:\n" . $output;
    
    $css = <<CSS;
div {
    -webkit-border-radius:  6px;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "-webkit-border-raduis was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'important--webkit-border-radius' => '6px', },
            },
        );
    $css = <<CSS;
div{-webkit-border-radius:6px !important;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "important -webkit-border-radius was:\n" . $output;
    
    $css = <<CSS;
div {
    -webkit-border-radius:  6px
                            !important;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "important -webkit-border-radius was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { '-webkit-border-radius-top-right' => '6px', },
            },
        );
    $css = <<CSS;
div{-webkit-border-radius-top-right:6px;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "important -webkit-border-radius was:\n" . $output;
    
    $css = <<CSS;
div {
    -webkit-border-radius-top-right: 6px;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "-webkit-border-radius-top-right was:\n" . $output;
}
