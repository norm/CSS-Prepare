use Modern::Perl;
use Test::More  tests => 4;

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


# color works
{
    $css = <<CSS;
        div { color: #fff; }
CSS
    @structure = (
            {
                original  => ' color: #fff; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'color' => '#fff', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "color value was:\n" . Dumper \@parsed;
}

# "colour" also works
{
    $css = <<CSS;
        div { colour: #ffffff; }
CSS
    @structure = (
            {
                original  => ' colour: #ffffff; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'color' => '#ffffff', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "'colour' value was:\n" . Dumper \@parsed;
}

# important
{
    $css = <<CSS;
        div { colour: #ffffff !important; }
CSS
    @structure = (
            {
                original  => ' colour: #ffffff !important; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'important-color' => '#ffffff', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "important colour was:\n" . Dumper \@parsed;
}

# invalid colour values are flagged
{
    $css = <<CSS;
        div { colour: violent; }
CSS
    @structure = (
            {
                original  => ' colour: violent; ',
                errors    => [
                    {
                        error => "invalid color value 'violent'",
                    },
                ],
                selectors => [ 'div' ],
                block     => {},
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "'colour' value was:\n" . Dumper \@parsed;
}
