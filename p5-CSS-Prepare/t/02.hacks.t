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
                        error => "invalid property 'voice-family'",
                    },
                    {
                        error => "invalid property 'voice-family'",
                    },
                ],
                block     => {
                    'width'        => '300px',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
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

    @parsed = $preparer->parse_string( $css );
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

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "underscore hack was:\n" . Dumper \@parsed;
}

# parse zoom:1
{
    $css = <<CSS;
        div { zoom: 1; }
CSS
    @structure = (
            {
                original  => ' zoom: 1; ',
                selectors => [ 'div' ],
                errors    => [],
                block     => {
                    'zoom'  => '1',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "zoom:1 hack was:\n" . Dumper \@parsed;
}
