use Modern::Perl;
use Test::More  tests => 12;

use CSS::Prepare;

my $preparer = CSS::Prepare->new( status => sub{} );
my( $input, $css, @structure, $output );



# empty stylesheets don't explode
{
    $css = '';
    
    @structure = $preparer->parse_string( $input );
    @structure = $preparer->optimise( @structure );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "empty content was:\n" . $output;
}

# broken stylesheets don't explode
{
    $input = q(bing);
    $css   = q();

    @structure = $preparer->parse_string( $input );
    @structure = $preparer->optimise( @structure );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "invalid stylesheet was:\n" . $output;
}

# multiple occurences of the same selector are combined
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
li{margin:0;padding:0;}
CSS
    
    @structure = $preparer->parse_string( $input );
    @structure = $preparer->optimise( @structure );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "selectors combine was:\n" . $output;
}

# multiple occurences of the same selector are combined even with 
# intervening code
{
    $input = <<CSS;
li { padding: 0; }
div { color: #000; }
li { margin: 0; }
CSS
    $css = <<CSS;
div{color:#000;}
li{margin:0;padding:0;}
CSS
    
    @structure = $preparer->parse_string( $input );
    @structure = $preparer->optimise( @structure );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "multiple selectors split apart was:\n" . $output;
}

# multiple occurences of the same property are combined
{
    $input = <<CSS;
div { margin: 0; }
li { margin: 0; }
CSS
    $css = <<CSS;
div,li{margin:0;}
CSS
    
    @structure = $preparer->parse_string( $input );
    @structure = $preparer->optimise( @structure );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "multiple properties combine was:\n" . $output;
}

# matching selectors and properties are combined
{
    $input = <<CSS;
div, li { padding: 0; }
div, li { margin: 0; }
li { color: red; }
CSS
    $css = <<CSS;
div,li{margin:0;padding:0;}
li{color:red;}
CSS
    
    @structure = $preparer->parse_string( $input );
    @structure = $preparer->optimise( @structure );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "matching selectors and properties combine was:\n" . $output;
}

# matching selectors and properties can be split if smaller output
{
    $input = <<CSS;
div, li { padding: 0; }
div, li { margin: 0; }
body { margin: 0; }
CSS
    $css = <<CSS;
body,div,li{margin:0;}
div,li{padding:0;}
CSS
    
    @structure = $preparer->parse_string( $input );
    @structure = $preparer->optimise( @structure );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "split multiple properties was:\n" . $output;
}

# matching selectors and properties can be split if smaller output
{
    $input = <<CSS;
div, li { padding: 0; }
div, li { margin: 0; }
li, fieldset { border: none; }
CSS
    $css = <<CSS;
div,li{margin:0;padding:0;}
fieldset,li{border:none;}
CSS
    
    @structure = $preparer->parse_string( $input );
    @structure = $preparer->optimise( @structure );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "split multiple properties was:\n" . $output;
}

# multiple choices of combinations result in the shortest string
{
    $input = <<CSS;
li { padding: 0; }
div { margin: 0; }
li { margin: 0; }
CSS
    $css = <<CSS;
div,li{margin:0;}
li{padding:0;}
CSS
    
    @structure = $preparer->parse_string( $input );
    @structure = $preparer->optimise( @structure );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "shortest string was:\n" . $output;
}

# existing combinations should be broken apart if it is shorter
{
    $input = <<CSS;
li { margin: 0; padding: 0; }
div { margin: 0; }
CSS
    $css = <<CSS;
div,li{margin:0;}
li{padding:0;}
CSS
    
    @structure = $preparer->parse_string( $input );
    @structure = $preparer->optimise( @structure );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "break existing combinations was:\n" . $output;
}

# complex example with multiple options
{
    $input = <<CSS;
li { margin: 0; }
div { margin: 0; }
li { padding: 0; }
fieldset { border: 1px solid #000; }
li { border: 1px solid #000; }
CSS
    $css = <<CSS;
div,li{margin:0;}
fieldset,li{border:1px solid #000;}
li{padding:0;}
CSS
    
    @structure = $preparer->parse_string( $input );
    @structure = $preparer->optimise( @structure );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "complex options was:\n" . $output;
}

# more complex example with multiple options and a crazy long selector
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
div#awesome-div,fieldset,li{border:1px solid #000;}
div,div#awesome-div,li{margin:0;}
li{padding:0;}
CSS
    
    @structure = $preparer->parse_string( $input );
    @structure = $preparer->optimise( @structure );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "more complex options was:\n" . $output;
}
