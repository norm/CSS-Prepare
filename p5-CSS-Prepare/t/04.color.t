use Modern::Perl;
use Test::More  tests => 16;

use CSS::Prepare;

my $preparer_concise = CSS::Prepare->new();
my $preparer_pretty  = CSS::Prepare->new( pretty => 1 );
my( $css, @structure, $output );



# basic colour works
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'color' => 'red',
                },
            },
        );
    $css = <<CSS;
div{color:red;}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "colour was:\n" . $output;
    
    $css = <<CSS;
div {
    color:                  red;
}
CSS
    
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "colour was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'important-color' => 'red',
                },
            },
        );
    $css = <<CSS;
div{color:red !important;}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "important colour was:\n" . $output;
    
    $css = <<CSS;
div {
    color:                  red
                            !important;
}
CSS
    
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "important colour was:\n" . $output;
}

# case is normalised
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'color' => '#FFF',
                },
            },
        );
    $css = <<CSS;
div{color:#fff;}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "normalised case was:\n" . $output;
    
    $css = <<CSS;
div {
    color:                  #fff;
}
CSS
    
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "normalised case was:\n" . $output;
}

# create shorthand colours where possible
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'color' => '#ffffff',
                },
            },
        );
    $css = <<CSS;
div{color:#fff;}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "collapsed to three-digit hex notation was:\n" . $output;
    
    $css = <<CSS;
div {
    color:                  #fff;
}
CSS
    
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "collapsed to three-digit hex notation was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'color' => '#000080',
                },
            },
        );
    $css = <<CSS;
div{color:navy;}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "keyword is shorter notation was:\n" . $output;
    
    $css = <<CSS;
div {
    color:                  navy;
}
CSS
    
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "keyword is shorter notation was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'color' => 'rgb( 204, 0, 0 )',
                },
            },
        );
    $css = <<CSS;
div{color:#c00;}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "RGB to hex notation was:\n" . $output;
    
    $css = <<CSS;
div {
    color:                  #c00;
}
CSS
    
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "RGB to hex notation was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'color' => 'rgb( 60%, 40%, 80% )',
                },
            },
        );
    $css = <<CSS;
div{color:#96c;}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "RGB to hex notation was:\n" . $output;
    
    $css = <<CSS;
div {
    color:                  #96c;
}
CSS
    
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "RGB to hex notation was:\n" . $output;
}

# don't break proper six-digit RGB notation
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'color' => '#ff0fff',
                },
            },
        );
    $css = <<CSS;
div{color:#ff0fff;}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "six-digit RGB notation was:\n" . $output;
    
    $css = <<CSS;
div {
    color:                  #ff0fff;
}
CSS
    
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "six-digit RGB notation was:\n" . $output;
}
