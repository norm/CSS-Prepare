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
body{font:13px/1.231 arial,helvetica,clean,sans-serif;*font-size:small;}
button,input,select,textarea{font:99% arial,helvetica,clean,sans-serif;}
table{font-size:inherit;}
code,kbd,pre,samp,tt{font-family:monospace;line-height:100%;*font-size:108%;}
CSS

    @structure = $preparer->parse_url(
                     'http://yui.yahooapis.com/2.8.0r4/build/fonts/fonts.css'
                 );
    
    my @errors = (
            { error => 'invalid font property: x-small' },
            { error => 'invalid font property: 100%' },
        );
    my @found_errors;
    foreach my $block ( @structure ) {
        foreach my $error ( @{$block->{'errors'}} ) {
            push @found_errors, @{$block->{'errors'}};
        }
    }
    is_deeply( \@errors, \@found_errors )
        or say "YUI fonts 2.8.0r4 errors was:\n" . Dumper \@errors;
    
    $output = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "YUI fonts 2.8.0r4 was:\n" . $output;
}
