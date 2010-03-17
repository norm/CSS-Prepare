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


# individual properties work
{
    $css = <<CSS;
        div { overflow: hidden; }
CSS
    @structure = (
            {
                original  => ' overflow: hidden; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'overflow' => 'hidden', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "overflow was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { clip: rect( 5px, 10px, 20px, auto ); }
CSS
    @structure = (
            {
                original  => ' clip: rect( 5px, 10px, 20px, auto ); ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 
                    'clip-rect-top'    => '5px', 
                    'clip-rect-right'  => '10px', 
                    'clip-rect-bottom' => '20px', 
                    'clip-rect-left'   => 'auto', 
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "clip was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { visibility: hidden; }
CSS
    @structure = (
            {
                original  => ' visibility: hidden; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'visibility' => 'hidden', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "visibility was:\n" . Dumper \@parsed;
}

# important
{
    $css = <<CSS;
        div { visibility: visible !important; }
CSS
    @structure = (
            {
                original  => ' visibility: visible !important; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 'important-visibility' => 'visible', },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "important visibility was:\n" . Dumper \@parsed;
}
