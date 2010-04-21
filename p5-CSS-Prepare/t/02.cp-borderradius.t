use Modern::Perl;
use Test::More  tests => 10;

use CSS::Prepare;
use Data::Dumper;
local $Data::Dumper::Terse     = 1;
local $Data::Dumper::Indent    = 1;
local $Data::Dumper::Useqq     = 1;
local $Data::Dumper::Deparse   = 1;
local $Data::Dumper::Quotekeys = 0;
local $Data::Dumper::Sortkeys  = 1;

my $preparer_with    = CSS::Prepare->new( extended => 1 );
my $preparer_without = CSS::Prepare->new( extended => 0 );
my( $css, @structure, @parsed );


# individual corners work
{
    $css = <<CSS;
        div { -cp-border-top-right-radius: 5px; }
CSS
    @structure = (
            {
                original  => ' -cp-border-top-right-radius: 5px; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    '-moz-border-radius-topright'     => '5px',
                    '-webkit-border-top-right-radius' => '5px',
                    'border-top-right-radius'         => '5px',
                },
            },
        );
    
    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "individual corner was:\n" . Dumper \@parsed;
    
    @structure = (
            {
                original  => ' -cp-border-top-right-radius: 5px; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    '-cp-border-top-right-radius' => '5px',
                },
            },
        );
    @parsed = $preparer_without->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "individual corner was:\n" . Dumper \@parsed;
}

# important works
{
    $css = <<CSS;
        div { -cp-border-top-right-radius: 5px !important; }
CSS
    @structure = (
            {
                original  => ' -cp-border-top-right-radius: 5px !important; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'important--moz-border-radius-topright'     => '5px',
                    'important--webkit-border-top-right-radius' => '5px',
                    'important-border-top-right-radius'         => '5px',
                },
            },
        );
    
    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "important individual corner was:\n" . Dumper \@parsed;
    
    @structure = (
        {
            original  => ' -cp-border-top-right-radius: 5px !important; ',
            errors    => [],
            selectors => [ 'div' ],
            block     => {
                'important--cp-border-top-right-radius'     => '5px',
            },
        },
    );
    
    @parsed = $preparer_without->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "important individual corner was:\n" . Dumper \@parsed;
}

# entire borders are expanded
{
    $css = <<CSS;
        div { -cp-border-radius: 5px; }
CSS
    @structure = (
            {
                original  => ' -cp-border-radius: 5px; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    '-moz-border-radius-topright'        => '5px',
                    '-moz-border-radius-topleft'         => '5px',
                    '-moz-border-radius-bottomright'     => '5px',
                    '-moz-border-radius-bottomleft'      => '5px',
                    '-webkit-border-top-right-radius'    => '5px',
                    '-webkit-border-top-left-radius'     => '5px',
                    '-webkit-border-bottom-right-radius' => '5px',
                    '-webkit-border-bottom-left-radius'  => '5px',
                    'border-top-right-radius'            => '5px',
                    'border-top-left-radius'             => '5px',
                    'border-bottom-right-radius'         => '5px',
                    'border-bottom-left-radius'          => '5px',
                },
            },
        );
    
    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "border radius was:\n" . Dumper \@parsed;
    
    @structure = (
            {
                original  => ' -cp-border-radius: 5px; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    '-cp-border-radius' => '5px',
                },
            },
        );
    
    @parsed = $preparer_without->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "border radius was:\n" . Dumper \@parsed;
}

# complex values are expanded
{
    $css = <<CSS;
        div { -cp-border-radius: 2em 1em 4em / 0.5em 3em; }
CSS
    @structure = (
            {
                original  => ' -cp-border-radius: 2em 1em 4em / 0.5em 3em; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    '-moz-border-radius-topleft'         => '2em 0.5em',
                    '-moz-border-radius-topright'        => '1em 3em',
                    '-moz-border-radius-bottomright'     => '4em 0.5em',
                    '-moz-border-radius-bottomleft'      => '1em 3em',
                    '-webkit-border-top-left-radius'     => '2em 0.5em',
                    '-webkit-border-top-right-radius'    => '1em 3em',
                    '-webkit-border-bottom-right-radius' => '4em 0.5em',
                    '-webkit-border-bottom-left-radius'  => '1em 3em',
                    'border-top-left-radius'             => '2em 0.5em',
                    'border-top-right-radius'            => '1em 3em',
                    'border-bottom-right-radius'         => '4em 0.5em',
                    'border-bottom-left-radius'          => '1em 3em',
                },
            },
        );
    
    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "border radius was:\n" . Dumper \@parsed;
    
    @structure = (
            {
                original  => ' -cp-border-radius: 2em 1em 4em / 0.5em 3em; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    '-cp-border-radius' => '2em 1em 4em / 0.5em 3em',
                },
            },
        );
    
    @parsed = $preparer_without->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "border radius was:\n" . Dumper \@parsed;

}

# overriding individual corners
{
    $css = <<CSS;
div {
    -cp-border-radius: 5px;
    -cp-border-top-left-radius: 0;
}
CSS
    @structure = (
            {
                original  => "\n    -cp-border-radius: 5px;\n"
                             . "    -cp-border-top-left-radius: 0;\n",
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    '-moz-border-radius-topright'        => '5px',
                    '-moz-border-radius-topleft'         => '0',
                    '-moz-border-radius-bottomright'     => '5px',
                    '-moz-border-radius-bottomleft'      => '5px',
                    '-webkit-border-top-right-radius'    => '5px',
                    '-webkit-border-top-left-radius'     => '0',
                    '-webkit-border-bottom-right-radius' => '5px',
                    '-webkit-border-bottom-left-radius'  => '5px',
                    'border-top-right-radius'            => '5px',
                    'border-top-left-radius'             => '0',
                    'border-bottom-right-radius'         => '5px',
                    'border-bottom-left-radius'          => '5px',
                },
            },
        );
    
    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "border radius was:\n" . Dumper \@parsed;
    
    @structure = (
            {
                original  => "\n    -cp-border-radius: 5px;\n"
                             . "    -cp-border-top-left-radius: 0;\n",
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    '-cp-border-radius'          => '5px',
                    '-cp-border-top-left-radius' => '0',
                },
            },
        );
    
    @parsed = $preparer_without->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "border radius was:\n" . Dumper \@parsed;
}
