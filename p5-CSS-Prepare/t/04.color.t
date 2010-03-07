use Modern::Perl;
use Test::More  tests => 5;

use CSS::Prepare;

my $preparer = CSS::Prepare->new();
my( $css, @structure, $output );


# create shorthand colours where possible
{
    @structure = (
            {
                selector => [ 'div' ],
                block => {
                    'color' => '#ffffff',
                },
            },
        );
    $css = <<CSS;
div{color:#fff;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "collapsed to three-digit hex notation was:\n" . $output;
}
{
    @structure = (
            {
                selector => [ 'div' ],
                block => {
                    'color' => '#000080',
                },
            },
        );
    $css = <<CSS;
div{color:navy;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "keyword is shorter notation was:\n" . $output;
}
{
    @structure = (
            {
                selector => [ 'div' ],
                block => {
                    'color' => 'rgb( 204, 0, 0 )',
                },
            },
        );
    $css = <<CSS;
div{color:#c00;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "RGB to hex notation was:\n" . $output;
}
{
    @structure = (
            {
                selector => [ 'div' ],
                block => {
                    'color' => 'rgb( 60%, 40%, 80% )',
                },
            },
        );
    $css = <<CSS;
div{color:#96c;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "RGB to hex notation was:\n" . $output;
}

# don't break proper six-digit RGB notation
{
    @structure = (
            {
                selector => [ 'div' ],
                block => {
                    'color' => '#ff0fff',
                },
            },
        );
    $css = <<CSS;
div{color:#ff0fff;}
CSS
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "six-digit RGB notation was:\n" . $output;
}

