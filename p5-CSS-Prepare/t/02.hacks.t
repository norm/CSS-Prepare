use Modern::Perl;
use Test::More  tests => 14;

use CSS::Prepare;
use Data::Dumper;
local $Data::Dumper::Terse     = 1;
local $Data::Dumper::Indent    = 1;
local $Data::Dumper::Useqq     = 1;
local $Data::Dumper::Deparse   = 1;
local $Data::Dumper::Quotekeys = 0;
local $Data::Dumper::Sortkeys  = 1;


my $preparer_with    = CSS::Prepare->new( hacks => 1 );
my $preparer_without = CSS::Prepare->new( hacks => 0 );
my( $css, @structure, @parsed );

# not tripped up by the box model hack
{
    $css = <<CSS;
        div {
            width: 400px; 
            voice-family: "\\"}\\""; 
            voice-family: inherit;
            width: 300px;
        } 
CSS
    @structure = (
            {
                original  => '
            width: 400px; 
            voice-family: "\"}\""; 
            voice-family: inherit;
            width: 300px;
        ',
                selectors => [ 'div' ],
                errors    => [
                    {
                        error => "invalid property: 'voice-family'",
                    },
                    {
                        error => "invalid property: 'voice-family'",
                    },
                ],
                block     => {
                    'width'        => '300px',
                },
            },
        );

    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "box model hack was:\n" . Dumper \@parsed;
    @parsed = $preparer_without->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "box model hack was:\n" . Dumper \@parsed;
}

# parse 'star hack'
{
    $css = <<CSS;
        div { color: red; *color: blue; }
CSS
    @structure = (
            {
                original  => ' color: red; *color: blue; ',
                selectors => [ 'div' ],
                errors    => [],
                block     => {
                    'color'  => 'red', 
                    '*color' => 'blue',
                },
            },
        );

    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "star hack was:\n" . Dumper \@parsed;
}
{
    @structure = (
            {
                original  => ' color: red; *color: blue; ',
                selectors => [ 'div' ],
                errors    => [
                    {
                        error => q(invalid property: '*color'),
                    },
                ],
                block     => {
                    'color'  => 'red',
                },
            },
        );

    @parsed = $preparer_without->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "star hack was:\n" . Dumper \@parsed;
}

# parse 'underscore hack'
{
    $css = <<CSS;
        div { color: red; _color: blue; }
CSS
    @structure = (
            {
                original  => ' color: red; _color: blue; ',
                selectors => [ 'div' ],
                errors    => [],
                block     => {
                    'color'  => 'red', 
                    '_color' => 'blue',
                },
            },
        );

    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "underscore hack was:\n" . Dumper \@parsed;
}
{
    @structure = (
            {
                original  => ' color: red; _color: blue; ',
                selectors => [ 'div' ],
                errors    => [
                    {
                        error => q(invalid property: '_color'),
                    },
                ],
                block     => {
                    'color'  => 'red',
                },
            },
        );

    @parsed = $preparer_without->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "underscore hack was:\n" . Dumper \@parsed;
}

# parse zoom:1 (not allowed without an IE hack)
{
    $css = <<CSS;
        div { _zoom: 1; }
CSS
    @structure = (
            {
                original  => ' _zoom: 1; ',
                selectors => [ 'div' ],
                errors    => [],
                block     => {
                    '_zoom'  => '1',
                },
            },
        );

    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "_zoom:1 hack was:\n" . Dumper \@parsed;
}
{
    @structure = (
            {
                original  => ' _zoom: 1; ',
                selectors => [ 'div' ],
                errors    => [
                    {
                        error => q(invalid property: '_zoom'),
                    },
                ],
                block     => {},
            },
        );

    @parsed = $preparer_without->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "_zoom:1 hack was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { zoom: 1; }
CSS
    @structure = (
            {
                original  => ' zoom: 1; ',
                selectors => [ 'div' ],
                errors    => [
                    {
                        error => q(invalid property: 'zoom'),
                    },
                ],
                block     => {},
            },
        );

    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "zoom:1 hack was:\n" . Dumper \@parsed;
}
{
    @parsed = $preparer_without->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "zoom:1 hack was:\n" . Dumper \@parsed;
}

# parse filter (not allowed without IE hack)
{
    $css = <<CSS;
        div { _filter: progid:DXImageTransform.Microsoft.gradient(startColorstr=#ff9999aa,endColorstr=#ff333344); }
CSS
    @structure = (
            {
                original  => ' _filter: progid:DXImageTransform.Microsoft.gradient(startColorstr=#ff9999aa,endColorstr=#ff333344); ',
                selectors => [ 'div' ],
                errors    => [],
                block     => {
                    '_filter'  => 'progid:DXImageTransform.Microsoft.gradient(startColorstr=#ff9999aa,endColorstr=#ff333344)',
                },
            },
        );

    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "_filter hack was:\n" . Dumper \@parsed;
}
{
    @structure = (
            {
                original  => ' _filter: progid:DXImageTransform.Microsoft.gradient(startColorstr=#ff9999aa,endColorstr=#ff333344); ',
                selectors => [ 'div' ],
                errors    => [
                    {
                        error => q(invalid property: '_filter'),
                    },
                ],
                block     => {},
            },
        );

    @parsed = $preparer_without->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "filter hack was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { filter: progid:DXImageTransform.Microsoft.gradient(startColorstr=#ff9999aa,endColorstr=#ff333344); }
CSS
    @structure = (
            {
                original  => ' filter: progid:DXImageTransform.Microsoft.gradient(startColorstr=#ff9999aa,endColorstr=#ff333344); ',
                selectors => [ 'div' ],
                errors    => [
                    {
                        error => q(invalid property: 'filter'),
                    },
                ],
                block     => {},
            },
        );

    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "filter hack was:\n" . Dumper \@parsed;
}
{
    @parsed = $preparer_without->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "filter hack was:\n" . Dumper \@parsed;
}
