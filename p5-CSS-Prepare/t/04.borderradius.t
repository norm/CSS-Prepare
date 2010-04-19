use Modern::Perl;
use Test::More  tests => 10;

use CSS::Prepare;

my $preparer_concise = CSS::Prepare->new();
my $preparer_pretty  = CSS::Prepare->new( pretty => 1 );
my( $css, @structure, $output );


# individual corners work
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'border-top-right-radius'         => '5px',
                },
            },
        );
    $css = <<CSS;
div{border-top-right-radius:5px;}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "individual corner was:\n" . $output;
    
    $css = <<CSS;
div {
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
                },
            },
        );
    $css = <<CSS;
div{border-top-right-radius:5px !important;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "important individual corner was:\n" . $output;
    
    $css = <<CSS;
div {
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
                },
            },
        );
    $css = <<CSS;
div{border-radius:5px;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "important individual corner was:\n" . $output;
    
    $css = <<CSS;
div {
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
                },
            },
        );
    $css = <<CSS;
div{border-radius:2em 1em 4em / 0.5em 3em;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "important individual corner was:\n" . $output;
    
    $css = <<CSS;
div {
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
                },
            },
        );
    
    $css = <<CSS;
div{border-radius:0 5px 5px;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "important individual corner was:\n" . $output;
    
    $css = <<CSS;
div {
    border-radius:          0 5px 5px;
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "important individual corner was:\n" . $output;
}
