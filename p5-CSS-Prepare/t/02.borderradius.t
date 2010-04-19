use Modern::Perl;
use Test::More  tests => 5;

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


# individual corners work
{
    $css = <<CSS;
        div { border-top-right-radius: 5px; }
CSS
    @structure = (
            {
                original  => ' border-top-right-radius: 5px; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'border-top-right-radius'         => '5px',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "individual corner was:\n" . Dumper \@parsed;
}

# important works
{
    $css = <<CSS;
        div { border-top-right-radius: 5px !important; }
CSS
    @structure = (
            {
                original  => ' border-top-right-radius: 5px !important; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'important-border-top-right-radius'         => '5px',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "important individual corner was:\n" . Dumper \@parsed;
}

# entire borders are expanded
{
    $css = <<CSS;
        div { border-radius: 5px; }
CSS
    @structure = (
            {
                original  => ' border-radius: 5px; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'border-top-right-radius'            => '5px',
                    'border-top-left-radius'             => '5px',
                    'border-bottom-right-radius'         => '5px',
                    'border-bottom-left-radius'          => '5px',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "border radius was:\n" . Dumper \@parsed;
}

# complex values are expanded
{
    $css = <<CSS;
        div { border-radius: 2em 1em 4em / 0.5em 3em; }
CSS
    @structure = (
            {
                original  => ' border-radius: 2em 1em 4em / 0.5em 3em; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'border-top-left-radius'             => '2em 0.5em',
                    'border-top-right-radius'            => '1em 3em',
                    'border-bottom-right-radius'         => '4em 0.5em',
                    'border-bottom-left-radius'          => '1em 3em',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "border radius was:\n" . Dumper \@parsed;
}

# overriding individual corners
{
    $css = <<CSS;
div {
    border-radius: 5px;
    border-top-left-radius: 0;
}
CSS
    @structure = (
            {
                original  => "\n    border-radius: 5px;\n"
                             . "    border-top-left-radius: 0;\n",
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'border-top-right-radius'            => '5px',
                    'border-top-left-radius'             => '0',
                    'border-bottom-right-radius'         => '5px',
                    'border-bottom-left-radius'          => '5px',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "border radius was:\n" . Dumper \@parsed;
}
