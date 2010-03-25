use Modern::Perl;
use Test::More  tests => 1;

use CSS::Prepare;

my $preparer = CSS::Prepare->new( silent => 1 );
my( $input, $css, @parsed, @structure, $output );



# empty stylesheets don't explode
{
    $css = '';
    @structure = ();
    
    @parsed    = $preparer->parse_string( $input );
    @structure = $preparer->optimise( @parsed );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "empty content was:\n" . $output;
}
