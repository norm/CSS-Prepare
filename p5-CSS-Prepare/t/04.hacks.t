use Modern::Perl;
use Test::More  tests => 6;

use CSS::Prepare;

my $preparer_with    = CSS::Prepare->new( hacks => 1 );
my $preparer_without = CSS::Prepare->new( hacks => 0 );
my( $css, @structure, $output );



# 'star hack'
{
    $css = <<CSS;
div{color:red;*color:blue;}
CSS
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'color'  => 'red',
                    '*color' => 'blue',
                },
            },
        );

    $output = $preparer_with->output_as_string( @structure );
    ok( $output eq $css )
        or say "star hack with hacks was:\n" . $output;
}
{
    $css = <<CSS;
div{color:red;*color:blue;}
CSS
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'color'  => 'red',
                    '*color' => 'blue',
                },
            },
        );

    $output = $preparer_without->output_as_string( @structure );
    ok( $output eq $css )
        or say "star hack without hacks was:\n" . $output;
}

# output 'underscore hack'
{
    $css = <<CSS;
div{color:red;_color:blue;}
CSS
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'color'  => 'red', 
                    '_color' => 'blue',
                },
            },
        );

    $output = $preparer_with->output_as_string( @structure );
    ok( $output eq $css )
        or say "underscore hack with hacks was:\n" . $output;
}
{
    $css = <<CSS;
div{color:red;_color:blue;}
CSS
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'color'  => 'red',
                    '_color' => 'blue',
                },
            },
        );

    $output = $preparer_without->output_as_string( @structure );
    ok( $output eq $css )
        or say "underscore hack without hacks was:\n" . $output;
}

# output 'zoom:1'
{
    $css = <<CSS;
div{zoom:1;}
CSS
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'zoom'  => '1',
                },
            },
        );

    $output = $preparer_with->output_as_string( @structure );
    ok( $output eq $css )
        or say "zoom:1 with hacks was:\n" . $output;
}
{
    $css = <<CSS;
div{zoom:1;}
CSS
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'zoom'  => '1',
                },
            },
        );

    $output = $preparer_without->output_as_string( @structure );
    ok( $output eq $css )
        or say "zoom:1 hack without hacks was:\n" . $output;
}

# TODO - check hacks come after properties
