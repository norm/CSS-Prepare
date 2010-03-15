use Modern::Perl;
use Test::More  tests => 3;

use CSS::Prepare;

my $preparer = CSS::Prepare->new();
my( $css, @structure, $output );


# individual properties work
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'overflow' => 'scroll', },
            },
        );
    $css = <<CSS;
div{overflow:scroll;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "overflow property was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { 
                    'clip-rect-top'    => '5px', 
                    'clip-rect-right'  => '10px', 
                    'clip-rect-bottom' => 'auto', 
                    'clip-rect-left'   => '8px', 
                },
            },
        );
    $css = <<CSS;
div{clip:rect(5px,10px,auto,8px);}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "clip property was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'visibility' => 'collapse', },
            },
        );
    $css = <<CSS;
div{visibility:collapse;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "visibility property was:\n" . $output;
}
