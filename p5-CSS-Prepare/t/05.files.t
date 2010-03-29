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

my $preparer = CSS::Prepare->new();
my( $css, @structure, $output );



# can output from a hierarchy of files
{
    $css = <<CSS;
div,li{margin:0;padding:0;}
li{margin-bottom:10px;margin-top:10px;}
CSS
    
    $preparer->set_base_directory( 't/css' );
    @structure = $preparer->parse_file_structure( '/site/subsite/basic.css' );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "simple file hierarchy test was:\n" . $output;
}
