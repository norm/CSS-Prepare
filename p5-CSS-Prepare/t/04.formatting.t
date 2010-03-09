use Modern::Perl;
use Test::More  tests => 5;

use CSS::Prepare;

my $preparer = CSS::Prepare->new();
my( $css, @structure, $output );


# individual properties work
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'display' => 'none', },
            },
        );
    $css = <<CSS;
div{display:none;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "display property was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { 
                    'position' => 'absolute', 
                    'top'      => '0', 
                    'right'    => '2em', 
                    'bottom'   => '10px', 
                    'left'     => '10%', 
                },
            },
        );
    $css = <<CSS;
div{bottom:10px;left:10%;position:absolute;right:2em;top:0;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "position property was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'float' => 'left', },
            },
        );
    $css = <<CSS;
div{float:left;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "display property was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'clear' => 'both', },
            },
        );
    $css = <<CSS;
div{clear:both;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "display property was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'z-index' => '50', },
            },
        );
    $css = <<CSS;
div{z-index:50;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "display property was:\n" . $output;
}
