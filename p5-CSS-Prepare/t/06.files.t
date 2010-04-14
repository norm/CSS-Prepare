use Modern::Perl;
use Test::More  tests => 1;

use CSS::Prepare;
use Data::Dumper;
local $Data::Dumper::Terse     = 1;
local $Data::Dumper::Indent    = 1;
local $Data::Dumper::Useqq     = 1;
local $Data::Dumper::Deparse   = 1;
local $Data::Dumper::Quotekeys = 0;
local $Data::Dumper::Sortkeys  = 1;

my $preparer = CSS::Prepare->new( status => sub{} );
my( $css, @parsed, @structure, $output );



# can output from a hierarchy of files
{
    $css = <<CSS;
div{margin:0;}
div,li{padding:0;}
li{margin:10px 0;}
CSS
    
    $preparer->set_base_directory( 't/css' );
    @parsed    = $preparer->parse_file_structure( '/site/subsite/basic.css' );
    @structure = $preparer->optimise( @parsed );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "stress test was:\n" . $output;
}
