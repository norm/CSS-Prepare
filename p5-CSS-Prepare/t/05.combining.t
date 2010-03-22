use Modern::Perl;
use Test::More  tests => 4;

use CSS::Prepare;

my $preparer = CSS::Prepare->new( silent => 1 );
my( $input, $css, @parsed, @structure, $output );



# test that overriding happens
{
    $input = <<CSS;
/* First things first, all comments should vanish. */

body {
    font-family: "Arial", "Helvetica", "clean", sans-serif;
    /* this will vanish - see later */
}

h1, h2, h3, h4, h5, h6,
ul, ol, li,
p, div {
    margin: 0;
    padding: 0;
    /* remains intact, with the exception of the list elements - see later */
}

#header-area,
blockquote,
li {
    border-bottom-style: dotted;
    border-top-style: dotted;
    border-left-style: dotted;
    border-right-style: dotted;    /* output: collapse all to border-style */
}
li {
    border-color: red;
    border-width: 1px;
    /* this triggers a "border:" shorthand on li, which should
     * then collapse down to a separate rule that is shorter
     * than just adding a new "li{border-color:red}" rule */
}


/* This section is a simulation of the effect of a local stylesheet overriding
 * a base stylesheet in a file/url structure. This is done by concatenating
 * each stylesheet from least- to most-specific, then parsing and
 * optimising the result as if it were one stylesheet (as this is). The
 * original declarations above should not be seen in the output. */
body {
    font-family: "Georgia";     /* replaces previous font-family */
}
ul, ol {
    margin-left: 2em;           /* ol&ul can no longer play the 
                                 * "margin:0;padding:0;" game */
}
li {
    margin-left: -2em;          /* ostracise li into its own rule set */
    list-style: disc inside;
}
CSS

    $css = <<CSS;
blockquote,#header-area{border-style:dotted;}
body{font-family:"Georgia";}
div,h1,h2,h3,h4,h5,h6,p{margin:0;padding:0;}
li{border:1px dotted red;margin:0 0 0 -2em;list-style:disc inside;}
li,ol,ul{padding:0;}
ol,ul{margin:0 0 0 2em;}
CSS
    
    @parsed    = $preparer->parse_string( $input );
    @structure = $preparer->optimise( @parsed );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "overriding test was:\n" . $output;
}

# test that combining files works -- should be identical to the simulated
# stylesheet above
{
    $preparer->set_base_directory( 't/css' );
    @parsed 
        = $preparer->parse_file_structure( '/site/subsite/combining.css' );
    @structure = $preparer->optimise( @parsed );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "combining test was:\n" . $output;
}

# test that imported base stylesheets work
{
    $css = <<CSS;
blockquote,#header-area{border-style:dotted;}
body{font-family:"Arial", "Helvetica", "clean", sans-serif;}
div,h1,h2,h3,h4,h5,h6,li,ol,p,ul{margin:0;padding:0;}
li{border:1px dotted red;}
body{font-family:"Georgia";}
li{list-style:disc inside;margin-left:-2em;}
ol,ul{margin-left:2em;}
CSS

    @parsed    = $preparer->parse_file( 't/css/combo-import.css' );
    @structure = $preparer->optimise( @parsed );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "imported file was:\n" . $output;
}

# test that media blocks work
{
    $css = <<CSS;
h1{background:#fff;}
h1,li{color:#999;}
\@media print {
  h1,li{color:#000;}
}
CSS

    @parsed    = $preparer->parse_file( 't/css/media.css' );
    @structure = $preparer->optimise( @parsed );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "media block was:\n" . $output;
}

