use Modern::Perl;
use Test::More  tests => 8;

use CSS::Prepare;

my $preparer = CSS::Prepare->new();
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

    $output = $preparer->output_as_string( @structure );
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

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "background color value was:\n" . $output;
}

# colours are shortened
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'color' => '#FFFFFF', },
            },
        );
    $css = <<CSS;
div{color:#fff;}
CSS

    $output = $preparer->output_as_string( @structure );
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

    $output = $preparer->output_as_string( @structure );
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

    $output = $preparer->output_as_string( @structure );
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

    $output = $preparer->output_as_string( @structure );
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
                    'background-position'        => 'left center',
                },
            },
        );
    $css = <<CSS;
div{background-attachment:fixed;background-color:#000;background-image:url(blah.gif) !important;background-position:left center;background-repeat:no-repeat;}
CSS

    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "background shorthanded value was:\n" . $output;
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
