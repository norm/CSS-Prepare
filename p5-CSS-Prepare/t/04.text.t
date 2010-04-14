use Modern::Perl;
use Test::More  tests => 16;

use CSS::Prepare;

my $preparer_concise = CSS::Prepare->new();
my $preparer_pretty  = CSS::Prepare->new( pretty => 1 );
my( $css, @structure, $output );



# individual properties work
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'text-indent' => '5px', },
            },
        );
    $css = <<CSS;
div{text-indent:5px;}
CSS
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "text indent property was:\n" . $output;
    $css = <<CSS;
div {
    text-indent:            5px;
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "text indent property was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'important-text-indent' => '5px', },
            },
        );
    $css = <<CSS;
div{text-indent:5px !important;}
CSS
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "text indent property was:\n" . $output;
    $css = <<CSS;
div {
    text-indent:            5px
                            !important;
}
CSS
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "text indent property was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'text-align' => 'center', },
            },
        );
    $css = <<CSS;
div{text-align:center;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "text align property was:\n" . $output;
    $css = <<CSS;
div {
    text-align:             center;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "text align property was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'a' ],
                block     => { 'text-decoration' => 'none', },
            },
        );
    $css = <<CSS;
a{text-decoration:none;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "text decoration property was:\n" . $output;
    $css = <<CSS;
a {
    text-decoration:        none;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "text decoration property was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'letter-spacing' => '1px', },
            },
        );
    $css = <<CSS;
div{letter-spacing:1px;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "letter spacing property was:\n" . $output;
    $css = <<CSS;
div {
    letter-spacing:         1px;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "letter spacing property was:\n" . $output;
}
{
      @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'word-spacing' => '5px', },
            },
        );
    $css = <<CSS;
div{word-spacing:5px;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "word spacing property was:\n" . $output;
    $css = <<CSS;
div {
    word-spacing:           5px;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "word spacing property was:\n" . $output;
}
{
      @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'text-transform' => 'uppercase', },
            },
        );
    $css = <<CSS;
div{text-transform:uppercase;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "text transform property was:\n" . $output;
    $css = <<CSS;
div {
    text-transform:         uppercase;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "text transform property was:\n" . $output;
}
{
      @structure = (
            {
                selectors => [ 'div' ],
                block     => { 'white-space' => 'nowrap', },
            },
        );
    $css = <<CSS;
div{white-space:nowrap;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "white space property was:\n" . $output;
    $css = <<CSS;
div {
    white-space:            nowrap;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "white space property was:\n" . $output;
}
