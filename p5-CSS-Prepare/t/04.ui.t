use Modern::Perl;
use Test::More  tests => 6;

use CSS::Prepare;

my $preparer = CSS::Prepare->new();
my( $css, @structure, $output );



# cursors
{
    $css = <<CSS;
a{cursor:url(blah.gif) crosshair;}
CSS
    @structure = (
            {
                selectors => [ 'a' ],
                block     => {
                    'cursor' => 'url(blah.gif) crosshair',
                },
            },
        );
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "cursor was:\n" . $output;
}

# outline-something properties
{
    $css = <<CSS;
div{outline-width:thin;}
CSS
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'outline-width' => 'thin',
                },
            },
        );
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "outline-width was:\n" . $output;
}
{
    $css = <<CSS;
div{outline-style:dotted;}
CSS
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'outline-style' => 'dotted',
                },
            },
        );
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "outline-style was:\n" . $output;
}
{
    $css = <<CSS;
div{outline-color:red;}
CSS
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'outline-color' => 'red',
                },
            },
        );
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "outline-width was:\n" . $output;
}

# outline shorthand property is expanded
{
    $css = <<CSS;
div{outline:1px solid blue;}
CSS
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'outline-width'    => '1px',
                    'outline-style'    => 'solid',
                    'outline-color'    => 'blue',
                },
            },
        );
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "outline shorthand was:\n" . $output;
}
{
    $css = <<CSS;
div{outline:2px dashed;}
CSS
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'outline-width'    => '2px',
                    'outline-style'    => 'dashed',
                    'outline-color'    => '',
                },
            },
        );
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "outline shorthand missing value was:\n" . $output;
}