use Modern::Perl;
use Test::More  tests => 3;

use CSS::Prepare;

my $preparer = CSS::Prepare->new();
my( $css, @structure, $output );


# individual properties work
{
    @structure = (
            {
                selector => [ 'div' ],
                block    => { 'background-color' => '#000', },
            },
        );
    $css = <<CSS;
div{background-color:#000;}
CSS

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "background color value was:\n" . $output;
}

# shorthand works
{
    @structure = (
            {
                selector => [ 'div' ],
                block    => { 
                    'background-color'      => '#000', 
                    'background-image'      => 'url(blah.gif)', 
                    'background-repeat'     => 'no-repeat', 
                    'background-attachment' => 'fixed', 
                    'background-position'   => 'center center', 
                },
            },
        );
    $css = <<CSS;
div{background:#000 url(blah.gif) no-repeat fixed center center;}
CSS

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "background shorthanded value was:\n" . $output;
}
{
    @structure = (
            {
                selector => [ 'div' ],
                block    => { 
                    'background-color'  => '#000', 
                    'background-image'  => 'url(blah.gif)', 
                    'background-repeat' => 'no-repeat', 
                },
            },
        );
    $css = <<CSS;
div{background:#000 url(blah.gif) no-repeat;}
CSS

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "background incomplete shorthanded value was:\n" . $output;
}

# don't clobber values when requested
#
# #thing li { background: ...}
# #thing li.blah { background-position: x y; background-repeat: none; }
#
# breaks "#thing li.blah" from using other bg values set in "#thing li"
# as they will be reset to initial values
# 
# #thing li.blah {
#     background-position: x y; 
#     background-repeat: none;
#     -cssprep-no-shorthand: 1;
# }
