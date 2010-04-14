use Modern::Perl;
use Test::More  tests => 22;

use CSS::Prepare;

my $preparer_concise = CSS::Prepare->new();
my $preparer_pretty  = CSS::Prepare->new( pretty => 1 );
my( $css, @structure, $output );


# individual properties work
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'font-size' => '13px', },
            },
        );
    $css = <<CSS;
div{font-size:13px;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "font size property was:\n" . $output;
    $css = <<CSS;
div {
    font-size:              13px;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "font size property was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'font-style' => 'italic', },
            },
        );
     $css = <<CSS;
div{font-style:italic;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "font style property was:\n" . $output;
     $css = <<CSS;
div {
    font-style:             italic;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "font style property was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'important-font-style' => 'italic', },
            },
        );
     $css = <<CSS;
div{font-style:italic !important;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "font style property was:\n" . $output;
     $css = <<CSS;
div {
    font-style:             italic
                            !important;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "font style property was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'abbr' ],
                block     => { 'font-variant' => 'normal', },
            },
        );
     $css = <<CSS;
abbr{font-variant:normal;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "font variant property was:\n" . $output;
     $css = <<CSS;
abbr {
    font-variant:           normal;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "font variant property was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'abbr' ],
                block     => { 'font-variant' => 'normal', },
            },
        );
     $css = <<CSS;
abbr{font-variant:normal;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "font variant property was:\n" . $output;
     $css = <<CSS;
abbr {
    font-variant:           normal;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "font variant property was:\n" . $output;
}

# shorthand works
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'font-style'   => 'italic',
                    'font-variant' => 'small-caps',
                    'font-weight'  => 'bold',
                    'font-size'    => '13px',
                    'font-family'  => '"Palatino"',
                },
            },
        );
    $css = <<CSS;
div{font:italic small-caps bold 13px "Palatino";}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "full font shorthand was:\n" . $output;
    $css = <<CSS;
div {
    font:                   italic
                            small-caps
                            bold
                            13px
                            "Palatino";
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "full font shorthand was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'line-height'  => '16px',
                    'font-style'   => '',
                    'font-variant' => 'small-caps',
                    'font-weight'  => '',
                    'font-size'    => '13px',
                    'font-family'  => '"Palatino", "Times New Roman"',
                },
            },
        );
    $css = <<CSS;
div{font:small-caps 13px/16px "Palatino","Times New Roman";}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "font shorthand with line-height was:\n" . $output;
    $css = <<CSS;
div {
    font:                   small-caps
                            13px/16px
                            "Palatino",
                            "Times New Roman";
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "font shorthand with line-height was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'important-line-height'  => '16px',
                    'important-font-style'   => '',
                    'important-font-variant' => 'small-caps',
                    'important-font-weight'  => '',
                    'important-font-size'    => '13px',
                    'important-font-family'  => '"Palatino","Times New Roman"',
                },
            },
        );
    $css = <<CSS;
div{font:small-caps 13px/16px "Palatino","Times New Roman" !important;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "important font shorthand was:\n" . $output;
    $css = <<CSS;
div {
    font:                   small-caps
                            13px/16px
                            "Palatino",
                            "Times New Roman"
                            !important;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "important font shorthand was:\n" . $output;
}

# shorthand is not invoked for only some font values
{
    @structure = (
            {
                selectors => [ 'p' ],
                block     => { 
                    'font-style'   => 'normal', 
                    'font-variant' => 'small-caps', 
                    'font-weight'  => 'bold', 
                },
            },
        );
     $css = <<CSS;
p{font-style:normal;font-variant:small-caps;font-weight:bold;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "no partial font shorthand was:\n" . $output;
     $css = <<CSS;
p {
    font-style:             normal;
    font-variant:           small-caps;
    font-weight:            bold;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "no partial font shorthand was:\n" . $output;
}

# line-height is separate when there is no font-size in the shorthand
{
    @structure = (
            {
                selectors => [ 'p' ],
                block     => { 
                    'font-style'   => '',
                    'font-variant' => '',
                    'font-weight'  => 'bold',
                    'font-size'    => '',
                    'line-height'  => '16px',
                    'font-family'  => '"Palatino"',
                },
            },
        );
     $css = <<CSS;
p{font:bold "Palatino";line-height:16px;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "no partial font shorthand was:\n" . $output;
     $css = <<CSS;
p {
    font:                   bold
                            "Palatino";
    line-height:            16px;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "no partial font shorthand was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'line-height'  => '16px',
                    'important-font-style'   => '',
                    'important-font-variant' => 'small-caps',
                    'important-font-weight'  => '',
                    'important-font-size'    => '13px',
                    'important-font-family'  => '"Palatino","Times New Roman"',
                },
            },
        );
    $css = <<CSS;
div{font:small-caps 13px "Palatino","Times New Roman" !important;line-height:16px;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "font shorthand with line-height was:\n" . $output;
    $css = <<CSS;
div {
    font:                   small-caps
                            13px
                            "Palatino",
                            "Times New Roman"
                            !important;
    line-height:            16px;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "font shorthand with line-height was:\n" . $output;
}
