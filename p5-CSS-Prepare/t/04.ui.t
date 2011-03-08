use Modern::Perl;
use Test::More  tests => 20;

use CSS::Prepare;

my $preparer_concise = CSS::Prepare->new();
my $preparer_pretty  = CSS::Prepare->new( pretty => 1 );
my( $css, @structure, $output );



# cursors
{
    @structure = (
            {
                selectors => [ 'a' ],
                block     => {
                    'cursor' => 'url(blah.gif) crosshair',
                },
            },
        );
    
    $css = <<CSS;
a{cursor:url(blah.gif) crosshair;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "cursor was:\n" . $output;
    
    $css = <<CSS;
a {
    cursor:                 url(blah.gif) crosshair;
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
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
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "outline-width was:\n" . $output;
    
    $css = <<CSS;
div {
    outline-width:          thin;
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "outline-width was:\n" . $output;
}
{
    $css = <<CSS;
div{outline-width:thin !important;}
CSS
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'important-outline-width' => 'thin',
                },
            },
        );
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "outline-width was:\n" . $output;
    
    $css = <<CSS;
div {
    outline-width:          thin
                            !important;
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
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
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "outline-style was:\n" . $output;
    
    $css = <<CSS;
div {
    outline-style:          dotted;
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
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
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "outline-width was:\n" . $output;
    
    $css = <<CSS;
div {
    outline-color:          red;
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "outline-width was:\n" . $output;
}

# outline colours are shortened
{
    $css = <<CSS;
div{outline-color:#ccc;}
CSS
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'outline-color' => '#CCCCCC',
                },
            },
        );
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "outline-color shortened was:\n" . $output;
    
    $css = <<CSS;
div {
    outline-color:          #ccc;
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "outline-color shortened was:\n" . $output;
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
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "outline shorthand was:\n" . $output;
    
    $css = <<CSS;
div {
    outline:                1px solid blue;
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
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
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "outline shorthand missing value was:\n" . $output;
    
    $css = <<CSS;
div {
    outline:                2px dashed;
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "outline shorthand missing value was:\n" . $output;
}

# outline is not expanded with missing values
{
    $css = <<CSS;
div{outline-color:blue;outline-width:1px;}
CSS
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'outline-width'    => '1px',
                    'outline-color'    => 'blue',
                },
            },
        );
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "outline shorthand was:\n" . $output;
    
    $css = <<CSS;
div {
    outline-color:          blue;
    outline-width:          1px;
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "outline shorthand was:\n" . $output;
}
{
    $css = <<CSS;
div{outline-color:blue;outline-style:solid !important;outline-width:1px;}
CSS
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'outline-width'    => '1px',
                    'important-outline-style'    => 'solid',
                    'outline-color'    => 'blue',
                },
            },
        );
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "outline shorthand was:\n" . $output;
    
    $css = <<CSS;
div {
    outline-color:          blue;
    outline-style:          solid
                            !important;
    outline-width:          1px;
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "outline shorthand was:\n" . $output;
}
