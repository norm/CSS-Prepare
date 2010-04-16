use Modern::Perl;
use Test::More  tests => 3;

use CSS::Prepare;
use Data::Dumper;
local $Data::Dumper::Terse     = 1;
local $Data::Dumper::Indent    = 1;
local $Data::Dumper::Useqq     = 1;
local $Data::Dumper::Deparse   = 1;
local $Data::Dumper::Quotekeys = 0;
local $Data::Dumper::Sortkeys  = 1;


my $preparer         = CSS::Prepare->new();
my $preparer_concise = CSS::Prepare->new();
my $preparer_pretty  = CSS::Prepare->new( pretty => 1 );
my( $css, @structure, @parsed, $output );



# detect plugins working
$css = <<CSS;
div {
    -cp-test-plugins: please;
    -cp-test-plugins: thanks;
}
CSS

@structure = (
        {
            original  => "\n    -cp-test-plugins: please;\n"
                         . "    -cp-test-plugins: thanks;\n",
            errors    => [
                {
                    error => "invalid plugin value 'please'"
                },
            ],
            selectors => [ 'div' ],
            block     => { 'plugin' => 'thanks', },
        },
    );
@parsed = $preparer->parse_string( $css );
is_deeply( \@structure, \@parsed )
    or say "plugins test value was:\n" . Dumper \@parsed;

$css = <<CSS;
div{plugin:thanks;}
CSS
$output = $preparer_concise->output_as_string( @structure );
ok( $output eq $css )
    or say "important colour was:\n" . $output;

$css = <<CSS;
div {
    plugin:                 thanks;
}
CSS
$output = $preparer_pretty->output_as_string( @structure );
ok( $output eq $css )
    or say "important colour was:\n" . $output;
