use Modern::Perl;
use Test::More  tests => 8;

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


# overflow works
{
    $css = <<CSS;
        div { -cp-contain: overflow; }
CSS
    @structure = (
            {
                original  => ' -cp-contain: overflow; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'overflow' => 'auto',
                },
            },
        );
    
    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "overflow was:\n" . Dumper \@parsed;
    
    @structure = (
            {
                original  => ' -cp-contain: overflow; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    '-cp-contain' => 'overflow',
                },
            },
        );
    @parsed = $preparer_without->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "overflow was:\n" . Dumper \@parsed;
}

# "easy" clearing works
{
    $css = <<CSS;
        div { -cp-contain: easy valid; }
CSS
    @structure = (
            {
                original  => ' -cp-contain: easy valid; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'display' => 'inline-block',
                },
            },
            {
                selectors => [ 'div:after' ],
                block => {
                    'content'    => '"."',
                    'display'    => 'block',
                    'height'     => '0',
                    'clear'      => 'both',
                    'visibility' => 'hidden',
                },
            },
            {   type => 'boundary', },
            {
                selectors => [ 'div' ],
                block     => {
                    'display' => 'block',
                },
            },
        );
    
    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "easy valid was:\n" . Dumper \@parsed;
    
    @structure = (
            {
                original  => ' -cp-contain: easy valid; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    '-cp-contain' => 'easy valid',
                },
            },
        );
    @parsed = $preparer_without->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "easy valid was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { -cp-contain: easy hack; }
CSS
    @structure = (
            {
                original  => ' -cp-contain: easy hack; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    '_zoom' => '1',
                },
            },
            {
                selectors => [ 'div:after' ],
                block => {
                    'content'    => '"."',
                    'display'    => 'block',
                    'height'     => '0',
                    'clear'      => 'both',
                    'visibility' => 'hidden',
                },
            },
        );
    
    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "easy hack was:\n" . Dumper \@parsed;
    
    @structure = (
            {
                original  => ' -cp-contain: easy hack; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    '-cp-contain' => 'easy hack',
                },
            },
        );
    @parsed = $preparer_without->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "easy hack was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        div { -cp-contain: easy; }
CSS
    @structure = (
            {
                original  => ' -cp-contain: easy; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    '_zoom' => '1',
                },
            },
            {
                selectors => [ 'div:after' ],
                block => {
                    'content'    => '"."',
                    'display'    => 'block',
                    'height'     => '0',
                    'clear'      => 'both',
                    'visibility' => 'hidden',
                },
            },
        );
    
    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "easy was:\n" . Dumper \@parsed;
    
    @structure = (
            {
                original  => ' -cp-contain: easy; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    '-cp-contain' => 'easy',
                },
            },
        );
    @parsed = $preparer_without->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "easy was:\n" . Dumper \@parsed;
}
