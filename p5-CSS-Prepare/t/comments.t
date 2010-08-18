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



# basic declaration block
{
    $css = <<CSS;
h1 {
    colour: red;        // yes, colour, because that's proper English
    font-size: 2em;
}
CSS
    @structure = (
            {
                original  => q(
    colour: red;        // yes, colour, because that's proper English
    font-size: 2em;
),
                selectors => [ 'h1' ],
                errors    => [
                    {
                        error => q(invalid property: '// yes, colour, because)
                                 . qq( that's proper English\n    font-size'),
                    }
                ],
                block     => {
                    'color' => 'red',
                },
            },
        );

    @parsed = $preparer_without->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "line-level comment was:\n" . Dumper \@parsed;
}

# basic declaration block
{
    $css = <<CSS;
h1 {
    colour: red;        // yes, colour, because that's proper English
    font-size: 2em;
}
CSS
    @structure = (
            {
                original  => q(
    colour: red;       
    font-size: 2em;
),
                selectors => [ 'h1' ],
                errors    => [],
                block     => {
                    'color' => 'red',
                    'font-size' => '2em',
                },
            },
        );

    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "line-level comment was:\n" . Dumper \@parsed;
}

# comment on a line by itself, also fine with no actual comment
{
    $css = <<CSS;
// This is the main logo
h1 { position: absolute; }
CSS
    @structure = (
            {
                original  => ' position: absolute; ',
                selectors => [ 'h1' ],
                errors    => [],
                block     => {
                    'position' => 'absolute',
                },
            },
        );

    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "line-level comment alone was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
//
h1 { position: absolute; }
CSS
    
    @parsed = $preparer_with->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "line-level comment without comment was:\n" . Dumper \@parsed;
}