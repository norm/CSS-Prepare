use Modern::Perl;
use Test::More  tests => 6;

use CSS::Prepare;

my $preparer_concise = CSS::Prepare->new( extended => 1, );
my $preparer_pretty  = CSS::Prepare->new( extended => 1, pretty => 1 );
my( $css, @structure, $output );


# overflow works
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'overflow' => 'auto',
                },
            },
        );
    
    $css = <<CSS;
div{overflow:auto;}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "overflow was:\n" . $output;
    
    $css = <<CSS;
div {
    overflow:               auto;
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "overflow was:\n" . $output;
}

# "easy" clearing works
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'display' => 'inline-block',
                },
            },
            {
                selectors => [ 'div:after' ],
                block => {
                    'content'    => '"."',
                    'display'    => 'block',
                    'height'     => '0',
                    'clear'      => 'both',
                    'visibility' => 'hidden',
                },
            },
            {   type => 'boundary', },
            {
                selectors => [ 'div' ],
                block     => {
                    'display' => 'block',
                },
            },
        );
    
    $css = <<CSS;
div{display:inline-block;}
div:after{clear:both;content:".";display:block;height:0;visibility:hidden;}
div{display:block;}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "easy valid was:\n" . $output;
    
    $css = <<CSS;
div {
    display:                inline-block;
}
div:after {
    clear:                  both;
    content:                ".";
    display:                block;
    height:                 0;
    visibility:             hidden;
}
div {
    display:                block;
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "easy valid was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    '_zoom' => '1',
                },
            },
            {
                selectors => [ 'div:after' ],
                block => {
                    'content'    => '"."',
                    'display'    => 'block',
                    'height'     => '0',
                    'clear'      => 'both',
                    'visibility' => 'hidden',
                },
            },
        );
    
    $css = <<CSS;
div{_zoom:1;}
div:after{clear:both;content:".";display:block;height:0;visibility:hidden;}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "easy hack was:\n" . $output;
    
    $css = <<CSS;
div {
    _zoom:                  1;
}
div:after {
    clear:                  both;
    content:                ".";
    display:                block;
    height:                 0;
    visibility:             hidden;
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "easy hack was:\n" . $output;
}
