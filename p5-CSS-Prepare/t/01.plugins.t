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
my $preparer_pretty  = CSS::Prepare->new( extended => 1, pretty => 1 );
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
            errors    => [],
            selectors => [ 'div' ],
            block     => {
                '-cp-test-plugins' => 'please',
                '-cp-test-plugins' => 'thanks',
            },
        },
    );
@parsed = $preparer_without->parse_string( $css );
is_deeply( \@structure, \@parsed )
    or say "no plugins without features was:\n" . Dumper \@parsed;

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
@parsed = $preparer_with->parse_string( $css );
is_deeply( \@structure, \@parsed )
    or say "plugins with features was:\n" . Dumper \@parsed;

$css = <<CSS;
div{plugin:thanks;}
CSS
$output = $preparer_with->output_as_string( @structure );
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
