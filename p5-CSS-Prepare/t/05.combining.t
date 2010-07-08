use Modern::Perl;
use Test::More;

use CSS::Prepare;

if ( $ENV{'OFFLINE'} ) {
    plan skip_all => 'Not online.';
    exit;
}
plan tests => 9;

my $preparer = CSS::Prepare->new();
my( $input, $css, @parsed, @structure, $output );
my $base_url = 'http://tests.cssprepare.com/';

if ( ! $preparer->has_http() ) {
    ok( 1 == 0, 'HTTP::Lite or LWP::UserAgent not found' );
}



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
body{font-family:"Arial","Helvetica","clean",sans-serif;}
div,h1,h2,h3,h4,h5,h6,li,ol,p,ul{margin:0;padding:0;}
blockquote,li,#header-area{border-style:dotted;}
li{border-color:red;border-width:1px;}
body{font-family:"Georgia";}
ol,ul{margin-left:2em;}
li{list-style:disc inside;margin-left:-2em;}
CSS
    
    @parsed    = $preparer->parse_string( $input );
    $output    = $preparer->output_as_string( @parsed );
    ok( $output eq $css )
        or say "overriding test was:\n" . $output;
}

# test that combining files works -- should be identical to the simulated
# stylesheet above
{
    $preparer->set_base_directory( 't/css' );
    @parsed 
        = $preparer->parse_file_structure( '/site/subsite/combining.css' );
    $output    = $preparer->output_as_string( @parsed );
    ok( $output eq $css )
        or say "combining test was:\n" . $output;
}

# test that imported base stylesheets work
{
    @parsed    = $preparer->parse_file( 't/css/combo-import.css' );
    $output    = $preparer->output_as_string( @parsed );
    ok( $output eq $css )
        or say "imported file was:\n" . $output;
}
{
    $css = <<CSS;
html{background:#fff;color:#000;}
blockquote,body,button,code,dd,div,dl,dt,fieldset,form,h1,h2,h3,h4,h5,h6,input,legend,li,ol,p,pre,td,textarea,th,ul{margin:0;padding:0;}
table{border-collapse:collapse;border-spacing:0;}
fieldset,img{border:0;}
address,caption,cite,code,dfn,em,optgroup,strong,th,var{font-style:inherit;font-weight:inherit;}
del,ins{text-decoration:none;}
li{list-style:none;}
caption,th{text-align:left;}
h1,h2,h3,h4,h5,h6{font-size:100%;font-weight:normal;}
q:after,q:before{content:'';}
abbr,acronym{border:0;font-variant:normal;}
sup{vertical-align:baseline;}
sub{vertical-align:baseline;}
legend{color:#000;}
button,input,optgroup,option,select,textarea{font-family:inherit;font-size:inherit;font-style:inherit;font-weight:inherit;}
button,input,select,textarea{*font-size:100%;}
CSS

    @parsed    = $preparer->parse_file( 't/css/import-reset.css' );
    $output    = $preparer->output_as_string( @parsed );
    ok( $output eq $css )
        or say "imported file was:\n" . $output;
}
{
    $css = <<CSS;
div,li{margin:0;padding:0;}
h1{padding:0;}
CSS

    $preparer->set_base_directory( 't/css' );
    @parsed    = $preparer->parse_stylesheet( "import-filebase.css" );
    $output    = $preparer->output_as_string( @parsed );
    ok( $output eq $css )
        or say "imported file was:\n" . $output;
}
{
    $css = <<CSS;
div,li{margin:0;padding:0;}
h1{padding:0;}
CSS

    @parsed    = $preparer->parse_stylesheet( "${base_url}/site/import.css" );
    $output    = $preparer->output_as_string( @parsed );
    ok( $output eq $css )
        or say "imported file was:\n" . $output;
}

# test that media blocks work
{
    $css = <<CSS;
h1{background:#fff;color:#999;}
li{color:#999;}
\@media print{
 h1{color:#000;}
 li{color:#000;}
}
CSS

    @parsed    = $preparer->parse_file( 't/css/media.css' );
    $output    = $preparer->output_as_string( @parsed );
    ok( $output eq $css )
        or say "media block was:\n" . $output;
}

# @import with a media query is output as an @media block
{
    $css = <<CSS;
\@media print{
 div{color:#000;}
}
CSS

    @parsed    = $preparer->parse_file( 't/css/import-media.css' );
    $output    = $preparer->output_as_string( @parsed );
    ok( $output eq $css )
        or say "media block was:\n" . $output;
}

# test that verbatim blocks are not optimised away
{
    $input = <<CSS;
body {
    margin: 0;
    padding: 0;
}
/*! verbatim */
p { margin: 0; }
/* -- */
li {
    margin: 0;
    padding: 0;
}
CSS

    $css = <<CSS;
body{margin:0;padding:0;}
p { margin: 0; }
li{margin:0;padding:0;}
CSS
    
    @parsed    = $preparer->parse_string( $input );
    $output    = $preparer->output_as_string( @parsed );
    ok( $output eq $css )
        or say "verbatim blocks test was:\n" . $output;
}
