use Modern::Perl;
use Test::More  tests => 12;

use CSS::Prepare;
use Data::Dumper;
local $Data::Dumper::Terse     = 1;
local $Data::Dumper::Indent    = 1;
local $Data::Dumper::Useqq     = 1;
local $Data::Dumper::Deparse   = 1;
local $Data::Dumper::Quotekeys = 0;
local $Data::Dumper::Sortkeys  = 1;

my $preparer = CSS::Prepare->new();
my( $css, @structure, @parsed );


# individual properties work
{
    $css = <<CSS;
        body { font-family: sans-serif; }
CSS
    @structure = (
            {
                original  => ' font-family: sans-serif; ',
                errors    => [],
                selectors => [ 'body' ],
                block     => { 'font-family' => 'sans-serif', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "font-family was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        body { font-family: "Arial", "Helvetica", "clean", sans-serif; }
CSS
    @structure = (
            {
                original  => ' font-family: "Arial", "Helvetica", "clean", sans-serif; ',
                errors    => [],
                selectors => [ 'body' ],
                block     => { 
                    'font-family' 
                        => q("Arial","Helvetica","clean",sans-serif), 
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "font-family multiple families was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { font-size: 13px; }
CSS
    @structure = (
            {
                original  => ' font-size: 13px; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'font-size' => '13px', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "font-size was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { font-style: italic; }
CSS
    @structure = (
            {
                original  => ' font-style: italic; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'font-style' => 'italic', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "font-style was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        h1 { font-variant: small-caps; }
CSS
    @structure = (
            {
                original  => ' font-variant: small-caps; ',
                errors    => [],
                selectors => [ 'h1' ],
                block     => { 'font-variant' => 'small-caps', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "font-variant was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        h1 { font-weight: 900; }
CSS
    @structure = (
            {
                original  => ' font-weight: 900; ',
                errors    => [],
                selectors => [ 'h1' ],
                block     => { 'font-weight' => '900', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "font-weight was:\n" . Dumper \@parsed;
}

# shorthand works
{
    $css = <<CSS;
        div { font: italic small-caps bold 13px/16px "Palatino"; }
CSS
    @structure = (
            {
                original  => ' font: italic small-caps'
                           . ' bold 13px/16px "Palatino"; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 
                    'font-style'   => 'italic',
                    'font-variant' => 'small-caps',
                    'font-weight'  => 'bold',
                    'font-size'    => '13px',
                    'line-height'  => '16px',
                    'font-family'  => '"Palatino"',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "full font shorthand was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { font: italic small-caps bold 13px/16px "Palatino" !important; }
CSS
    @structure = (
            {
                original  => ' font: italic small-caps'
                           . ' bold 13px/16px "Palatino" !important; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'important-font-style'   => 'italic',
                    'important-font-variant' => 'small-caps',
                    'important-font-weight'  => 'bold',
                    'important-font-size'    => '13px',
                    'important-line-height'  => '16px',
                    'important-font-family'  => '"Palatino"',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "important full font shorthand was:\n" . Dumper \@parsed;
}

# shorthand with the first three properties in a different order
{
    $css = <<CSS;
        div { font: 700 oblique normal 13px/1.2 sans-serif; }
CSS
    @structure = (
            {
                original  => ' font: 700 oblique normal'
                           . ' 13px/1.2 sans-serif; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'font-style'   => 'oblique',
                    'font-variant' => 'normal',
                    'font-weight'  => '700',
                    'font-size'    => '13px',
                    'line-height'  => '1.2',
                    'font-family'  => 'sans-serif',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "different order font shorthand was:\n" . Dumper \@parsed;
}

# need a minimum of size and family for it to be a valid shorthand
{
    $css = <<CSS;
        div { font: bold italic; }
CSS
    @structure = (
            {
                original  => ' font: bold italic; ',
                errors    => [
                    {
                        error => 'invalid font property: bold italic',
                    }
                ],
                selectors => [ 'div' ],
                block     => {},
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "important full font shorthand was:\n" . Dumper \@parsed;
}

# cannot switch size and family in order
{
    $css = <<CSS;
        div { font: Verdana 10px; }
CSS
    @structure = (
            {
                original  => ' font: Verdana 10px; ',
                errors    => [
                    {
                        error => 'invalid font property: Verdana 10px',
                    }
                ],
                selectors => [ 'div' ],
                block     => {},
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "important full font shorthand was:\n" . Dumper \@parsed;
}

# reduce whitespace in font-family
{
    $css = <<CSS;
    pre code {
        font:                   95%
                                'Menlo',
                                'Inconsolata',
                                'Consolas',
                                'Panic Sans',
                                'Bitstream Vera Sans Mono',
                                'Courier',
                                monospace;
    }
CSS
    @structure = (
            {
                original  => q(
        font:                   95%
                                'Menlo',
                                'Inconsolata',
                                'Consolas',
                                'Panic Sans',
                                'Bitstream Vera Sans Mono',
                                'Courier',
                                monospace;
    ),
                errors    => [],
                selectors => [ 'pre code' ],
                block     => {
                    'font-style'   => '',
                    'font-variant' => '',
                    'font-weight'  => '',
                    'font-size'    => '95%',
                    'line-height'  => '',
                    'font-family'  => q('Menlo','Inconsolata','Consolas',)
                                      . q('Panic Sans','Bitstream Vera )
                                      . q(Sans Mono','Courier',monospace),
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "reduce font-family was:\n" . Dumper \@parsed;
}


