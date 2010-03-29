use Modern::Perl;
use Test::More  tests => 6;

use CSS::Prepare;

my $preparer = CSS::Prepare->new();
my( $input, $css, @structure, $output );



# empty stylesheets don't explode
{
    $css = '';
    @structure = ();
    
    @structure = $preparer->parse_string( $input );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "empty content was:\n" . $output;
}

# broken stylesheets don't explode
{
    $input = q(bing);
    $css   = q();

    @structure = $preparer->parse_string( $input );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "invalid stylesheet was:\n" . $output;
}

# multiple occurences of the same selector
{
    $input = <<CSS;
li { 
    margin: 0; 
}
li { 
    padding: 0; 
}
CSS
    $css = <<CSS;
li{margin:0;}
li{padding:0;}
CSS
    
    @structure = $preparer->parse_string( $input );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "selectors combine was:\n" . $output;
}

# multiple occurences of the same selector with intervening code
{
    $input = <<CSS;
li { padding: 0; }
div { color: #000; }
li { margin: 0; }
CSS
    $css = <<CSS;
li{padding:0;}
div{color:#000;}
li{margin:0;}
CSS
    
    @structure = $preparer->parse_string( $input );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "multiple selectors split apart was:\n" . $output;
}

# multiple properties and selectors are not split, but are alphabetised
{
    $input = <<CSS;
li, div { padding: 0; margin: 0; }
CSS
    $css = <<CSS;
div,li{margin:0;padding:0;}
CSS
    
    @structure = $preparer->parse_string( $input );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "alphabetise properties and selectors was:\n" . $output;
}

# complex example with multiple options and a crazy long selector
{
    $input = <<CSS;
div { margin: 0; }
li { padding: 0; }
fieldset { border: 1px solid #000; }
li { border: 1px solid #000; }
div#awesome-div { margin: 0; border: 1px solid #000; }
li { margin: 0; }
CSS
    $css = <<CSS;
div{margin:0;}
li{padding:0;}
fieldset{border:1px solid #000;}
li{border:1px solid #000;}
div#awesome-div{border:1px solid #000;margin:0;}
li{margin:0;}
CSS
    
    @structure = $preparer->parse_string( $input );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "more complex options was:\n" . $output;
}
