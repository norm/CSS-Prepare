use Modern::Perl;
use Test::More  tests => 18;

use CSS::Prepare;

my $preparer_concise = CSS::Prepare->new();
my $preparer_pretty  = CSS::Prepare->new( pretty => 1 );
my( $css, @structure, $output );


# individual properties work
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'background-color' => '#000', },
            },
        );
    $css = <<CSS;
div{background-color:#000;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "background color value was:\n" . $output;
    
    $css = <<CSS;
div {
    background-color:       #000;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "background color value was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'important-background-color' => '#000', },
            },
        );
    $css = <<CSS;
div{background-color:#000 !important;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "background color value was:\n" . $output;
    
    $css = <<CSS;
div {
    background-color:       #000
                            !important;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "background color value was:\n" . $output;
}

# colours are shortened
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'background-color' => '#FFFFFF', },
            },
        );
    $css = <<CSS;
div{background-color:#fff;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "background color shortening was:\n" . $output;
    
    $css = <<CSS;
div {
    background-color:       #fff;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "background color shortening was:\n" . $output;
}

# shorthand works
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'background-color'      => '#000', 
                    'background-image'      => 'url(blah.gif)', 
                    'background-repeat'     => 'no-repeat', 
                    'background-attachment' => 'fixed', 
                    'background-position'   => 'center right',
                },
            },
        );
    $css = <<CSS;
div{background:#000 url(blah.gif) no-repeat fixed center right;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "background shorthanded value was:\n" . $output;
    
    $css = <<CSS;
div {
    background:             #000
                            url(blah.gif)
                            no-repeat
                            fixed
                            center right;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "background shorthanded value was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'background-color'      => '#000',
                    'background-image'      => 'url(blah.gif)',
                    'background-repeat'     => 'no-repeat',
                    'background-attachment' => '',
                    'background-position'   => '',
                },
            },
        );
    $css = <<CSS;
div{background:#000 url(blah.gif) no-repeat;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "background incomplete shorthanded value was:\n" . $output;
    
    $css = <<CSS;
div {
    background:             #000
                            url(blah.gif)
                            no-repeat;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "background incomplete shorthanded value was:\n" . $output;
}

# no shorthand with missing values
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'background-color'      => '#000',
                    'background-image'      => 'url(blah.gif)',
                    'background-repeat'     => 'no-repeat',
                },
            },
        );
    $css = <<CSS;
div{background-color:#000;background-image:url(blah.gif);background-repeat:no-repeat;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "background incomplete shorthanded value was:\n" . $output;
    
    $css = <<CSS;
div {
    background-color:       #000;
    background-image:       url(blah.gif);
    background-repeat:      no-repeat;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "background incomplete shorthanded value was:\n" . $output;
}

# important
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'important-background-color'  => '#000',
                    'important-background-image'  => 'url(blah.gif)',
                    'important-background-repeat' => 'no-repeat',
                    'important-background-attachment' => '',
                    'important-background-position' => '',
                },
            },
        );
    $css = <<CSS;
div{background:#000 url(blah.gif) no-repeat !important;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "important background incomplete shorthanded value was:\n"
               . $output;
    
    $css = <<CSS;
div {
    background:             #000
                            url(blah.gif)
                            no-repeat
                            !important;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "important background incomplete shorthanded value was:\n"
               . $output;
}

# no shorthand when one property is important (so no full complement)
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'background-color'           => '#000',
                    'important-background-image' => 'url(blah.gif)',
                    'background-repeat'          => 'no-repeat',
                    'background-attachment'      => 'fixed',
                    'background-position'        => 'left top',
                },
            },
        );
    $css = <<CSS;
div{background-attachment:fixed;background-color:#000;background-image:url(blah.gif) !important;background-position:left top;background-repeat:no-repeat;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "background shorthanded value was:\n" . $output;
    
    $css = <<CSS;
div {
    background-attachment:  fixed;
    background-color:       #000;
    background-image:       url(blah.gif)
                            !important;
    background-position:    left top;
    background-repeat:      no-repeat;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "background shorthanded value was:\n" . $output;
}

# don't emit second value when it is center for background-position
{
    @structure = (
        {
            selectors => [ 'div' ],
            block     => {
                'background-position'        => 'center center',
            },
        },
        {
            selectors => [ 'h1' ],
            block     => {
                'background-position'        => '20px center',
            },
        },
        );
    $css = <<CSS;
div{background-position:center;}
h1{background-position:20px;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "background shorthanded value was:\n" . $output;
    
    $css = <<CSS;
div {
    background-position:    center;
}
h1 {
    background-position:    20px;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "background shorthanded value was:\n" . $output;
}
