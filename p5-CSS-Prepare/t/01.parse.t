use Modern::Perl;
use Test::More  tests => 28;

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



# don't explode on an empty stylesheet
{
    $css = q();
    @structure = ();

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "empty stylesheet was:\n" . Dumper \@parsed;
}

# basic declaration block
{
    $css = <<CSS;
        h1 { color: red; }
CSS
    @structure = (
            {
                original  => ' color: red; ',
                selectors => [ 'h1' ],
                errors    => [],
                block     => {
                    'color' => 'red',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "basic declaration was:\n" . Dumper \@parsed;
}

# basic declaration block with lots of whitespace
{
    $css = <<CSS;
        h1 { 
            color      : red; 
        }
CSS
    @structure = (
            {
                original  => q( 
            color      : red; 
        ),
                selectors => [ 'h1' ],
                errors    => [],
                block     => {
                    'color' => 'red',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "basic declaration with whitespace was:\n" . Dumper \@parsed;
}

# basic declaration block with no whitespace
{
    $css = q(h1{color:red;}h1{color:blue;});
    @structure = (
            {
                original  => 'color:red;',
                selectors => [ 'h1' ],
                errors    => [],
                block     => {
                    'color' => 'red',
                },
            },
            {
                original  => 'color:blue;',
                selectors => [ 'h1' ],
                errors    => [],
                block     => {
                    'color' => 'blue',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "basic declaration with no whitespace was:\n" . Dumper \@parsed;
}

# skip declaration blocks with no properties
{
    $css = <<CSS;
        div { color: red; }
        h1  {}
        div { font-size: 10px; }
CSS
    @structure = (
            {
                original  => ' color: red; ',
                selectors => [ 'div' ],
                errors    => [],
                block     => {
                    'color' => 'red',
                },
            },
            {
                original  => ' font-size: 10px; ',
                selectors => [ 'div' ],
                errors    => [],
                block     => {
                    'font-size' => '10px',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "skip empty blocks was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
h1 {}
CSS
    @structure = (
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "entirely empty content was:\n" . Dumper \@parsed;
}

# basic declaration block with comments
{
    $css = <<CSS;
        /* ignore me */
        h1 { 
        /* only one rule here
            background:     blue;
        */  
            color: 
                            red; 
        }
CSS
    @structure = (
            {
                original  => q( 
          
            color: 
                            red; 
        ),
                selectors => [ 'h1' ],
                errors    => [],
                block     => {
                    'color' => 'red',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "basic declaration with whitespace was:\n" . Dumper \@parsed;
}

# basic declaration block, no semi-colon on last value
{
    $css = <<CSS;
        h1 { color: red }
CSS
    @structure = (
            {
                original  => ' color: red ',
                selectors => [ 'h1' ],
                errors    => [],
                block     => {
                    'color' => 'red',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "basic stylesheet no semi-colon was:\n" . Dumper \@parsed;
}

# basic declaration block, with important keyword
{
    $css = <<CSS;
        h1 { color: red !important; }
CSS
    @structure = (
            {
                original  => ' color: red !important; ',
                selectors => [ 'h1' ],
                errors    => [],
                block     => {
                    'important-color' => 'red',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "important declaration was:\n" . Dumper \@parsed;
}

# basic declaration block, with important keyword using whitespace
{
    $css = <<CSS;
        h1 { color: red ! /* hello */ important; }
CSS
    @structure = (
            {
                original  => ' color: red !  important; ',
                selectors => [ 'h1' ],
                errors    => [],
                block     => {
                    'important-color' => 'red',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "important declaration with whitespace was:\n" . Dumper \@parsed;
}

# multiple declaration blocks
{
    $css = <<CSS;
        h1 { color: red; }
        #header { font-size: 13px; }
        p, li { margin-top: 5px; margin-bottom: 5px; }
CSS
    @structure = (
            {
                original  => q( color: red; ),
                selectors => [ 'h1' ],
                errors    => [],
                block     => {
                    'color' => 'red',
                },
            },
            {
                original  => q( font-size: 13px; ),
                selectors => [ '#header' ],
                errors    => [],
                block     => {
                    'font-size' => '13px',
                },
            },
            {
                original  => q( margin-top: 5px; margin-bottom: 5px; ),
                selectors => [ 'p', 'li' ],
                errors    => [],
                block     => {
                    'margin-top'    => '5px',
                    'margin-bottom' => '5px',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "basic stylesheet was:\n" . Dumper \@parsed;
}

# braces within rules or comments should not be seen as block delimiters
{
    $css = <<CSS;
        /* div { color: #000; } */
        div { color: #333; }
        li:after { content: "}"; }
CSS
    @structure = (
            {
                original  => ' color: #333; ',
                selectors => [ 'div' ],
                errors    => [],
                block     => {
                    'color' => '#333',
                },
            },
            {
                original  => ' content: "}"; ',
                selectors => [ 'li:after' ],
                errors    => [],
                block     => {
                    'content' => '"}"',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "braces not as delimiters was:\n" . Dumper \@parsed;
}

# escaped quotes within quotes are passed through
{
    $css = <<CSS;
        li:before { content: "a\\"b"; }
CSS
    @structure = (
            {
                original  => ' content: "a\"b"; ',
                selectors => [ 'li:before' ],
                errors    => [],
                block     => {
                    'content' => '"a\"b"',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "braces not as delimiters was:\n" . Dumper \@parsed;
}

# invalid properties are flagged
{
    $css = <<CSS;
        div { colur: #fff; }
CSS
    @structure = (
            {
                original  => ' colur: #fff; ',
                selectors => [ 'div' ],
                errors    => [
                    {
                        error => q(invalid property: 'colur'),
                    },
                ],
                block     => {},
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "invalid property 'colur' was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { bing; }
CSS
    @structure = (
            {
                original  => ' bing; ',
                selectors => [ 'div' ],
                errors    => [
                    {
                        error => q(invalid property: 'bing;'),
                    },
                ],
                block     => {},
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "invalid property 'bing' was:\n" . Dumper \@parsed;
}

# selectors remain unharmed
{
    $css = <<CSS;
        div
        p { color: red; }
CSS
    @structure = (
            {
                original  => ' color: red; ',
                selectors => [ qq(div p) ],
                errors    => [],
                block     => {
                    'color' => 'red',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "selectors unharmed was:\n" . Dumper \@parsed;
}

# test multiple selectors
{
    $css = <<CSS;
        div p p { color: #000; }
CSS
    @structure = (
            {
                original  => ' color: #000; ',
                selectors => [ 'div p p' ],
                errors    => [],
                block     => {
                    'color' => '#000',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "multiple selectors was:\n" . Dumper \@parsed;
}

# CSS 2.1 #4.1.7:
# "For example, since the "&" is not a valid token in a CSS 2.1 selector, a 
#  CSS 2.1 user agent must ignore the whole second line, and not set the color
#  of H3 to red""
{
    $css = <<CSS;
        h1, h2 {color: green }
        h3, h4 & h5 {color: red }
        h6 {color: black }
CSS
    @structure = (
            {
                original  => 'color: green ',
                selectors => [ 'h1', 'h2' ],
                errors    => [],
                block     => {
                    'color' => 'green',
                },
            },
            {
                original  => 'color: red ',
                selectors => [],
                errors    => [
                    {
                        error => 'ignored block - unknown selector'
                               . q( 'h4 & h5' (CSS 2.1 #4.1.7)),
                    },
                ],
                block     => {},
            },
            {
                original  => 'color: black ',
                selectors => [ 'h6' ],
                errors    => [],
                block     => {
                    'color' => 'black',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "invalid selector was:\n" . Dumper \@parsed;
}

# supported character set
{
    $css = <<CSS;
\@charset "UTF-8";
h1 { color: red; }
CSS
    @structure = (
            {
                original  => ' color: red; ',
                selectors => [ 'h1' ],
                errors    => [],
                block     => {
                    'color' => 'red',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "supported charset was:\n" . Dumper \@parsed;
}

# unsupported character set
{
    $css = <<CSS;
\@charset "ISO-8859-1";
body { color: #000; }
CSS
    @structure = (
            {
                errors    => [
                    { fatal => q(Unsupported charset 'ISO-8859-1'), }
                ],
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "unsupported charset was:\n" . Dumper \@parsed;
}

# ignore character set after start of document
{
    $css = <<CSS;
        h1 { color: red; }
        \@charset "UTF-8";
CSS
    @structure = (
            {
                original  => ' color: red; ',
                selectors => [ 'h1' ],
                errors    => [],
                block     => {
                    'color' => 'red',
                },
            },
            {
                errors => [
                    {
                        error => '@charset rule inside stylsheet -- '
                                 . 'ignored (CSS 2.1 #4.4)',
                    }
                ],
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "invalid later charset was:\n" . Dumper \@parsed;
}

# split out media blocks
{
    $css = <<CSS;
body { color: #999; }
\@media print {
    body {
        color: #000;
    }
}
h1 { color: red; }
CSS
    @structure = (
            {
                original  => ' color: #999; ',
                selectors => [ 'body' ],
                errors    => [],
                block     => {
                    'color' => '#999',
                },
            },
            {
                type      => 'at-media',
                query     => 'print',
                blocks    => [
                    {
                        original  => '
        color: #000;
    ',
                        selectors => [ 'body' ],
                        errors    => [],
                        block     => {
                            'color' => '#000',
                        },
                    },
                ],
            },
            {
                original  => ' color: red; ',
                selectors => [ 'h1' ],
                errors    => [],
                block     => {
                    'color' => 'red',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "\@media block was:\n" . Dumper \@parsed;
}

# CSS3 media queries
{
    $css = <<CSS;
\@media screen and ( -webkit-min-device-pixel-ratio: 0 ) {
    h1 { color: red; }
}
CSS
    @structure = (
            {
                type      => 'at-media',
                query
                    => 'screen and ( -webkit-min-device-pixel-ratio: 0 )',
                blocks    => [
                    {
                        original  => ' color: red; ',
                        selectors => [ 'h1' ],
                        errors    => [],
                        block     => {
                            'color' => 'red',
                        },
                    },
                ],
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "CSS3 \@media query was:\n" . Dumper \@parsed;
}

# not a stylesheet
{
    $css = <<CSS;
I am not a stylesheet.
CSS
    @structure = (
            {
                errors => [
                    {
                        error => "Unknown content:\n" .
                                 "I am not a stylesheet.\n\n",
                    }
                ],
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "not a stylesheet was:\n" . Dumper \@parsed;
}


# chunking boundaries
{
    $css = <<CSS;
li { color: #000; }
/* -- */
h1 { color: #000; }
CSS
    my $css2 = <<CSS;
li { color: #000; }
/* ---- */
h1 { color: #000; }
CSS
    @structure = (
            {
                original  => ' color: #000; ',
                selectors => [ 'li' ],
                errors    => [],
                block     => {
                    'color' => '#000',
                },
            },
            { type => 'boundary', },
            {
                original  => ' color: #000; ',
                selectors => [ 'h1' ],
                errors    => [],
                block     => {
                    'color' => '#000',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "chunked content was:\n" . Dumper \@parsed;
}

# verbatim comments
{
    $css = <<CSS;
/*! IE hack */
CSS
    @structure = (
            {
                type => 'verbatim',
                string => "/* IE hack */\n",
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "verbatim comment was:\n" . Dumper \@parsed;
}

# verbatim blocks
{
    $css = <<CSS;
/*! verbatim */
div {
    blah: 0;
}
/* -- */
div { color: black; }
CSS
    @structure = (
            {
                type => 'verbatim',
                string => "div {\n    blah: 0;\n}\n",
            },
            {
                original  => ' color: black; ',
                selectors => [ 'div' ],
                errors    => [],
                block     => {
                    'color' => 'black',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "verbatim block was:\n" . Dumper \@parsed;
    
    $css = <<CSS;
/*! verbatim */
div {
    blah: 0;
}
/* ---- */
div { color: black; }
CSS
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "verbatim block was:\n" . Dumper \@parsed;
}
