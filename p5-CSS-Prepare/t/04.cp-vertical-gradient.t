use Modern::Perl;
use Test::More  tests => 2;

use CSS::Prepare;

my $preparer_concise = CSS::Prepare->new( extended => 1, );
my $preparer_pretty  = CSS::Prepare->new( extended => 1, pretty => 1 );
my( $css, @structure, $output );



# gradients work
{
    @structure = (
            {
                original  => ' -cp-vertical-gradient: white, red; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    "*filter" => "progid:DXImageTransform.Microsoft.gradient(startColorstr='#fff',endColorstr='red')",
                    "-ms-filter" => "progid:DXImageTransform.Microsoft.gradient(startColorstr='#fff',endColorstr='red')",
                },
            },
            {
                selectors => [ 'div' ],
                block     => {
                    'background-image' => "-webkit-gradient(linear,left top,left bottom,from(#fff),to(red))",
                },
            },
            {
                selectors => [ 'div' ],
                block     => {
                    'background-image' => "-moz-linear-gradient(top,#fff,red)",
                },
            },
        );
    
    $css = <<CSS;
div{-ms-filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#fff',endColorstr='red');*filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#fff',endColorstr='red');}
div{background-image:-webkit-gradient(linear,left top,left bottom,from(#fff),to(red));}
div{background-image:-moz-linear-gradient(top,#fff,red);}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "overflow was:\n" . $output;
    
    $css = <<CSS;
div {
    -ms-filter:             progid:DXImageTransform.Microsoft.gradient(startColorstr='#fff',endColorstr='red');
    *filter:                progid:DXImageTransform.Microsoft.gradient(startColorstr='#fff',endColorstr='red');
}
div {
    background-image:       -webkit-gradient(linear,left top,left bottom,from(#fff),to(red));
}
div {
    background-image:       -moz-linear-gradient(top,#fff,red);
}
CSS
    
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "overflow was:\n" . $output;
}
