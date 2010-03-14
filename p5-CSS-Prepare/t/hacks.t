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
my( $css, @structure, @parsed );

# not tripped up by the box model hack
{
    $css = <<CSS;
        div {
            width: 400px; 
            voice-family: "\\"}\\""; 
            voice-family: inherit;
            width: 300px;
        } 
CSS
    @structure = (
            {
                original  => '
            width: 400px; 
            voice-family: "\"}\""; 
            voice-family: inherit;
            width: 300px;
        ',
                selectors => [ 'div' ],
                errors    => [
                    {
                        error => "invalid property 'voice-family'",
                    },
                    {
                        error => "invalid property 'voice-family'",
                    },
                ],
                block     => {
                    'width'        => '300px',
                },
            },
        );

    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "box model hack was:\n" . Dumper \@parsed;
}

