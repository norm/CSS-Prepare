use Modern::Perl;
use Test::More  tests => 10;

use CSS::Prepare;

my $preparer_concise = CSS::Prepare->new( extended => 1, );
my $preparer_pretty  = CSS::Prepare->new( extended => 1, pretty => 1 );
my( $css, @structure, $output );


# individual corners work
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    '-moz-border-radius-topright'     => '5px',
                    '-webkit-border-top-right-radius' => '5px',
                    'border-top-right-radius'         => '5px',
                },
            },
        );
    $css = <<CSS;
div{-moz-border-radius-topright:5px;-webkit-border-top-right-radius:5px;border-top-right-radius:5px;}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "individual corner was:\n" . $output;
    
    $css = <<CSS;
div {
    -moz-border-radius-topright: 5px;
    -webkit-border-top-right-radius: 5px;
    border-top-right-radius: 5px;
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "individual corner was:\n" . $output;
}

# important works
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'important-border-top-right-radius'         => '5px',
                    'important--moz-border-radius-topright'     => '5px',
                    'important--webkit-border-top-right-radius' => 
'5px',
                },
            },
        );
    $css = <<CSS;
div{-moz-border-radius-topright:5px !important;-webkit-border-top-right-radius:5px !important;border-top-right-radius:5px !important;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "important individual corner was:\n" . $output;
    
    $css = <<CSS;
div {
    -moz-border-radius-topright: 5px
                            !important;
    -webkit-border-top-right-radius: 5px
                            !important;
    border-top-right-radius: 5px
                            !important;
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "important individual corner was:\n" . $output;
}

# entire borders are expanded
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'border-top-right-radius'            => '5px',
                    'border-top-left-radius'             => '5px',
                    'border-bottom-right-radius'         => '5px',
                    'border-bottom-left-radius'          => '5px',
                    '-moz-border-radius-topright'        => '5px',
                    '-moz-border-radius-topleft'         => '5px',
                    '-moz-border-radius-bottomright'     => '5px',
                    '-moz-border-radius-bottomleft'      => '5px',
                    '-webkit-border-top-right-radius'    => '5px',
                    '-webkit-border-top-left-radius'     => '5px',
                    '-webkit-border-bottom-right-radius' => '5px',
                    '-webkit-border-bottom-left-radius'  => '5px',
                },
            },
        );
    $css = <<CSS;
div{-moz-border-radius:5px;-webkit-border-radius:5px;border-radius:5px;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "important individual corner was:\n" . $output;
    
    $css = <<CSS;
div {
    -moz-border-radius:     5px;
    -webkit-border-radius:  5px;
    border-radius:          5px;
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "important individual corner was:\n" . $output;
}

# complex values are collapsed
{
    @structure = (
            {
                original  => ' -cp-border-radius: 2em 1em 4em / 0.5em 3em; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'border-top-left-radius'             => '2em 0.5em',
                    'border-top-right-radius'            => '1em 3em',
                    'border-bottom-right-radius'         => '4em 0.5em',
                    'border-bottom-left-radius'          => '1em 3em',
                    '-moz-border-radius-topleft'         => '2em 0.5em',
                    '-moz-border-radius-topright'        => '1em 3em',
                    '-moz-border-radius-bottomright'     => '4em 0.5em',
                    '-moz-border-radius-bottomleft'      => '1em 3em',
                    '-webkit-border-top-left-radius'     => '2em 0.5em',
                    '-webkit-border-top-right-radius'    => '1em 3em',
                    '-webkit-border-bottom-right-radius' => '4em 0.5em',
                    '-webkit-border-bottom-left-radius'  => '1em 3em',
                },
            },
        );
    $css = <<CSS;
div{-moz-border-radius:2em 1em 4em / 0.5em 3em;-webkit-border-radius:2em 1em 4em / 0.5em 3em;border-radius:2em 1em 4em / 0.5em 3em;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "important individual corner was:\n" . $output;
    
    $css = <<CSS;
div {
    -moz-border-radius:     2em 1em 4em / 0.5em 3em;
    -webkit-border-radius:  2em 1em 4em / 0.5em 3em;
    border-radius:          2em 1em 4em / 0.5em 3em;
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "important individual corner was:\n" . $output;
}

# overriding individual corners
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'border-top-right-radius'            => '5px',
                    'border-top-left-radius'             => '0',
                    'border-bottom-right-radius'         => '5px',
                    'border-bottom-left-radius'          => '5px',
                    '-moz-border-radius-topright'        => '5px',
                    '-moz-border-radius-topleft'         => '0',
                    '-moz-border-radius-bottomright'     => '5px',
                    '-moz-border-radius-bottomleft'      => '5px',
                    '-webkit-border-top-right-radius'    => '5px',
                    '-webkit-border-top-left-radius'     => '0',
                    '-webkit-border-bottom-right-radius' => '5px',
                    '-webkit-border-bottom-left-radius'  => '5px',
                },
            },
        );
    
    $css = <<CSS;
div{-moz-border-radius:0 5px 5px;-webkit-border-radius:0 5px 5px;border-radius:0 5px 5px;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "important individual corner was:\n" . $output;
    
    $css = <<CSS;
div {
    -moz-border-radius:     0 5px 5px;
    -webkit-border-radius:  0 5px 5px;
    border-radius:          0 5px 5px;
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "important individual corner was:\n" . $output;
}
