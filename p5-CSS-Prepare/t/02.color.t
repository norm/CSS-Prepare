use Modern::Perl;
use Test::More  tests => 2;

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
                selector => [ 'div' ],
                block    => { 'color' => '#fff', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "color value was:\n" . Dumper \@parsed;
}

# "colour" also works
{
    $css = <<CSS;
        div { colour: #fff; }
CSS
    @structure = (
            {
                selector => [ 'div' ],
                block    => { 'color' => '#fff', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "'colour' value was:\n" . Dumper \@parsed;
}
