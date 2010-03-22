use Modern::Perl;
use Test::More  tests => 1;

use CSS::Prepare;

my $preparer = CSS::Prepare->new( silent => 1 );
my( @structure, $output, $css );

if ( ! $preparer->has_http() ) {
    ok( 1 == 0, 'HTTP::Lite or LWP::UserAgent not found' );
}


{
    $css = <<CSS;
abbr,acronym{border:0;font-variant:normal;}
address,caption,cite,code,dfn,em,strong,th,var{font-style:inherit;font-weight:inherit;}
blockquote,body,button,code,dd,div,dl,dt,fieldset,form,h1,h2,h3,h4,h5,h6,input,legend,li,ol,p,pre,td,textarea,th,ul{margin:0;padding:0;}
button,input,optgroup,option,select,textarea{font-family:inherit;font-size:inherit;font-style:inherit;font-weight:inherit;}
button,input,select,textarea{*font-size:100%;}
caption,th{text-align:left;}
del,ins{text-decoration:none;}
fieldset,img{border:0;}
h1,h2,h3,h4,h5,h6{font-size:100%;font-weight:normal;}
html{background:#fff;}
html,legend{color:#000;}
li{list-style:none;}
q:after,q:before{content:'';}
sub,sup{vertical-align:baseline;}
table{border-collapse:collapse;border-spacing:0;}
CSS

    @structure = $preparer->parse_url(
                     'http://yui.yahooapis.com/2.8.0r4/build/reset/reset.css'
                 );
    
    foreach my $block ( @structure ) {
        foreach my $error ( @{$block->{'errors'}} ) {
            my( $type, $text ) = each %{$error};
            say uc( $type ) . ": $text";
        }
    }
    
    @structure = $preparer->optimise( @structure );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "YUI reset 2.8.0r4 was:\n" . $output;
}
