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

my $preparer_with    = CSS::Prepare->new( extended => 1 );
my $preparer_without = CSS::Prepare->new( extended => 0 );
my( $css, @structure, @parsed );


# gradients work
{
    $css = <<CSS;
        div { -cp-vertical-gradient: white, red; }
CSS
    @structure = (
            {
                original  => ' -cp-vertical-gradient: white, red; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    "*filter" => "progid:DXImageTransform.Microsoft.gradient(startColorstr='#fff',endColorstr='red')",
                    "-ms-filter" => "progid:DXImageTransform.Microsoft.gradient(startColorstr='#fff',endColorstr='red')",
                },
            },
            {
                selectors => [ 'div' ],
                block     => {
                    'background-image' => "-webkit-gradient(linear,left top,left bottom,from(#fff),to(red))",
                },
            },
            {
                selectors => [ 'div' ],
                block     => {
                    'background-image' => "-moz-linear-gradient(top,#fff,red)",
                },
            },
        );
    
    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "vertical gradient was:\n" . Dumper \@parsed;
    
    @structure = (
            {
                original  => ' -cp-vertical-gradient: white, red; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    '-cp-vertical-gradient' => 'white, red',
                },
            },
        );
    @parsed = $preparer_without->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "vertical gradient was:\n" . Dumper \@parsed;

}
