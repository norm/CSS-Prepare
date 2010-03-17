use Modern::Perl;
use Test::More  tests => 8;

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
        div { text-indent: 5px; }
CSS
    @structure = (
            {
                original  => ' text-indent: 5px; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'text-indent' => '5px', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "font size property was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { text-align: center; }
CSS
    @structure = (
            {
                original  => ' text-align: center; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'text-align' => 'center', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "font size property was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        a { text-decoration: none; }
CSS
    @structure = (
            {
                original  => ' text-decoration: none; ',
                errors    => [],
                selectors => [ 'a' ],
                block     => { 'text-decoration' => 'none', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "font size property was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { letter-spacing: 1px; }
CSS
    @structure = (
            {
                original  => ' letter-spacing: 1px; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'letter-spacing' => '1px', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "font size property was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { word-spacing: 5px; }
CSS
    @structure = (
            {
                original  => ' word-spacing: 5px; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'word-spacing' => '5px', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "font size property was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { text-transform: uppercase; }
CSS
    @structure = (
            {
                original  => ' text-transform: uppercase; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'text-transform' => 'uppercase', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "font size property was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { white-space: nowrap; }
CSS
    @structure = (
            {
                original  => ' white-space: nowrap; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'white-space' => 'nowrap', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "font size property was:\n" . Dumper \@parsed;
}

# important
{
    $css = <<CSS;
        div { text-align: justify !important; }
CSS
    @structure = (
            {
                original  => ' text-align: justify !important; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'important-text-align' => 'justify', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "important text-align was:\n" . Dumper \@parsed;
}
