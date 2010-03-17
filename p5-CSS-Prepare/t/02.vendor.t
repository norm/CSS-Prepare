use Modern::Perl;
use Test::More  tests => 3;

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


# vendor extensions are preserved
{
    $css = <<CSS;
        div { -moz-background-clip: -moz-initial; }
CSS
    @structure = (
            {
                original  => ' -moz-background-clip: -moz-initial; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { '-moz-background-clip' => '-moz-initial', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "-moz-background-clip value was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { -webkit-border-radius: 6px; }
CSS
    @structure = (
            {
                original  => ' -webkit-border-radius: 6px; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { '-webkit-border-radius' => '6px', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "-webkit-border-raduis was:\n" . Dumper \@parsed;
}

# important
{
    $css = <<CSS;
        div { -webkit-border-radius: 0 !important; }
CSS
    @structure = (
            {
                original  => ' -webkit-border-radius: 0 !important; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'important--webkit-border-radius' => '0', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "important -webkit-border-raduis was:\n" . Dumper \@parsed;
}
