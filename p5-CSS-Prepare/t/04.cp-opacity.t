use Modern::Perl;
use Test::More  tests => 2;

use CSS::Prepare;

my $preparer_concise = CSS::Prepare->new( extended => 1, );
my $preparer_pretty  = CSS::Prepare->new( extended => 1, pretty => 1 );
my( $css, @structure, $output );


# opacity is expanded
{
    @structure = (
            {
                original  => ' -cp-opacity: 0.5; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'opacity'    => '0.5',
                    '-ms-filter' => 'progid:DXImageTransform.Microsoft.'
                                    . 'Alpha(Opacity=50)',
                    '*filter'    => 'alpha(opacity=50)',
                },
            },
        );
    $css = <<CSS;
div{-ms-filter:progid:DXImageTransform.Microsoft.Alpha(Opacity=50);opacity:0.5;*filter:alpha(opacity=50);}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "overflow was:\n" . $output;
    
    $css = <<CSS;
div {
    -ms-filter:             progid:DXImageTransform.Microsoft.Alpha(Opacity=50);
    opacity:                0.5;
    *filter:                alpha(opacity=50);
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "overflow was:\n" . $output;
}
