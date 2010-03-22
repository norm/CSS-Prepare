use Modern::Perl;
use Test::More  tests => 2;

use CSS::Prepare;
use Data::Dumper;
local $Data::Dumper::Terse     = 1;
local $Data::Dumper::Indent    = 1;
local $Data::Dumper::Useqq     = 1;
local $Data::Dumper::Deparse   = 1;
local $Data::Dumper::Quotekeys = 0;
local $Data::Dumper::Sortkeys  = 1;

my $preparer = CSS::Prepare->new( silent => 1 );
my( @structure, $output, $css );

if ( ! $preparer->has_http() ) {
    ok( 1 == 0, 'HTTP::Lite or LWP::UserAgent not found' );
}


{
    $css = <<CSS;
body{font-size:13px;line-height:1.231;*font-family:x-small;*font-size:small;}
body,button,input,select,textarea{font-family:arial,helvetica,clean,sans-serif;}
button,input,select,textarea{font-size:99%;}
code,kbd,pre,samp,tt{font-family:monospace;line-height:100%;*font-size:108%;}
table{font-size:inherit;}
CSS

    @structure = $preparer->parse_url(
                     'http://yui.yahooapis.com/2.8.0r4/build/fonts/fonts.css'
                 );
    
    my @errors = ({ error => 'invalid font property: 100%' });
    my @found_errors;
    foreach my $block ( @structure ) {
        foreach my $error ( @{$block->{'errors'}} ) {
            push @found_errors, @{$block->{'errors'}};
        }
    }
    is_deeply( \@errors, \@found_errors )
        or say "YUI fonts 2.8.0r4 errors was:\n" . Dumper \@errors;
    
    @structure = $preparer->optimise( @structure );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "YUI fonts 2.8.0r4 was:\n" . $output;
}
