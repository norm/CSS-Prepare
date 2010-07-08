use Modern::Perl;
use Test::More  tests => 4;

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


# opacity is expanded
{
    $css = <<CSS;
        div { -cp-opacity: 0.5; }
CSS
    @structure = (
            {
                original  => ' -cp-opacity: 0.5; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'opacity'    => '0.5',
                    '-ms-filter' => 'progid:DXImageTransform.Microsoft.'
                                    . 'Alpha(Opacity=50)',
                    '*filter'    => 'alpha(opacity=50)',
                },
            },
        );
    
    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "opacity was:\n" . Dumper \@parsed;
    
    @structure = (
            {
                original  => ' -cp-opacity: 0.5; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    '-cp-opacity' => '0.5',
                },
            },
        );
    @parsed = $preparer_without->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "overflow was:\n" . Dumper \@parsed;
}

# out-of-bounds values are flagged
{
    $css = <<CSS;
        div { -cp-opacity: 1.1; }
CSS
    @structure = (
            {
                original  => ' -cp-opacity: 1.1; ',
                errors    => [
                    {
                        error => "invalid opacity value: '1.1'",
                    },
                ],
                selectors => [ 'div' ],
                block     => {
                    '-ms-filter' => 'progid:DXImageTransform.Microsoft.'
                                    . 'Alpha(Opacity=110)',
                    '*filter'    => 'alpha(opacity=110)',
                },
            },
        );
    
    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "opacity was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { -cp-opacity: -0.1; }
CSS
    @structure = (
            {
                original  => ' -cp-opacity: -0.1; ',
                errors    => [
                    {
                        error => "invalid opacity value: '-0.1'",
                    },
                ],
                selectors => [ 'div' ],
                block     => {
                    '-ms-filter' => 'progid:DXImageTransform.Microsoft.'
                                    . 'Alpha(Opacity=-10)',
                    '*filter'    => 'alpha(opacity=-10)',
                },
            },
        );
    
    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "opacity was:\n" . Dumper \@parsed;
}
