use Modern::Perl;
use Test::More;

use CSS::Prepare;
use Data::Dumper;
local $Data::Dumper::Terse     = 1;
local $Data::Dumper::Indent    = 1;
local $Data::Dumper::Useqq     = 1;
local $Data::Dumper::Deparse   = 1;
local $Data::Dumper::Quotekeys = 0;
local $Data::Dumper::Sortkeys  = 1;

if ( $ENV{'OFFLINE'} ) {
    plan skip_all => 'Not online.';
    exit;
}
plan tests => 2;

my $preparer = CSS::Prepare->new();
my( @structure, $output, $css );

if ( ! $preparer->has_http() ) {
    ok( 1 == 0, 'HTTP::Lite or LWP::UserAgent not found' );
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

    @structure = $preparer->parse_url(
                     'http://yui.yahooapis.com/2.8.0r4/build/reset/reset.css'
                 );
    
    my @errors = ();
    my @found_errors;
    foreach my $block ( @structure ) {
        foreach my $error ( @{$block->{'errors'}} ) {
            push @found_errors, @{$block->{'errors'}};
        }
    }
    is_deeply( \@errors, \@found_errors )
        or say "YUI reset 2.8.0r4 errors was:\n" . Dumper \@errors;
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "YUI reset 2.8.0r4 was:\n" . $output;
}
