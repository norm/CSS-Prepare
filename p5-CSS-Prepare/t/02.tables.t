use Modern::Perl;
use Test::More  tests => 6;

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


# check properties
{
    $css = <<CSS;
        caption { caption-side: top; }
CSS
    @structure = (
            {
                original  => ' caption-side: top; ',
                errors    => [],
                selectors => [ 'caption' ],
                block     => {
                    'caption-side' => 'top',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "caption-side was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        table { table-layout: auto; }
CSS
    @structure = (
            {
                original  => ' table-layout: auto; ',
                errors    => [],
                selectors => [ 'table' ],
                block     => {
                    'table-layout' => 'auto',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "table-layout was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        table { border-collapse: separate; }
CSS
    @structure = (
            {
                original  => ' border-collapse: separate; ',
                errors    => [],
                selectors => [ 'table' ],
                block     => {
                    'border-collapse' => 'separate',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "border-collapse was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        table { border-spacing: 2px 0; }
CSS
    @structure = (
            {
                original  => ' border-spacing: 2px 0; ',
                errors    => [],
                selectors => [ 'table' ],
                block     => {
                    'border-spacing' => '2px 0',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "border-spacing was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        table { empty-cells: hide; }
CSS
    @structure = (
            {
                original  => ' empty-cells: hide; ',
                errors    => [],
                selectors => [ 'table' ],
                block     => {
                    'empty-cells' => 'hide',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "empty-cells was:\n" . Dumper \@parsed;
}

# important
{
    $css = <<CSS;
        table { border-collapse: separate !important; }
CSS
    @structure = (
            {
                original  => ' border-collapse: separate !important; ',
                errors    => [],
                selectors => [ 'table' ],
                block     => {
                    'important-border-collapse' => 'separate',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "border-collapse was:\n" . Dumper \@parsed;
}
