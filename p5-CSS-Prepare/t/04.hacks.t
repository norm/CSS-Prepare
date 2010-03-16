use Modern::Perl;
use Test::More  tests => 2;

use CSS::Prepare;

my $preparer = CSS::Prepare->new();
my( $css, @structure, $output );



# output 'star hack'
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

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "star hack was:\n" . $output;
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

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "underscore hack was:\n" . $output;
}

