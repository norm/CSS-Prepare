use Modern::Perl;
use Test::More  tests => 21;

use CSS::Prepare;

my $preparer_with           = CSS::Prepare->new( hacks => 1 );
my $preparer_with_pretty    = CSS::Prepare->new( hacks => 1, pretty => 1 );
my $preparer_without        = CSS::Prepare->new( hacks => 0 );
my( $css, @structure, $output );



# 'star hack'
{
    $css = <<CSS;
div{color:red;*color:blue;}
CSS
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'color'  => 'red',
                    '*color' => 'blue',
                },
            },
        );

    $output = $preparer_with->output_as_string( @structure );
    ok( $output eq $css )
        or say "star hack with hacks was:\n" . $output;
    $output = $preparer_without->output_as_string( @structure );
    ok( $output eq $css )
        or say "star hack without hacks was:\n" . $output;
    
    $css = <<CSS;
div {
    color:                  red;
    *color:                 blue;
}
CSS
    $output = $preparer_with_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "star hack with hacks was:\n" . $output;
}

# 'underscore hack'
{
    $css = <<CSS;
div{color:red;_color:blue;}
CSS
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'color'  => 'red', 
                    '_color' => 'blue',
                },
            },
        );

    $output = $preparer_with->output_as_string( @structure );
    ok( $output eq $css )
        or say "underscore hack with hacks was:\n" . $output;
    $output = $preparer_without->output_as_string( @structure );
    ok( $output eq $css )
        or say "underscore hack without hacks was:\n" . $output;
    
    $css = <<CSS;
div {
    color:                  red;
    _color:                 blue;
}
CSS
    $output = $preparer_with_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "underscore hack without hacks was:\n" . $output;
}

# 'zoom:1'
{
    $css = <<CSS;
div{zoom:1;}
CSS
    @structure = (
            {
                selectors => [ 'div' ],
                block     => {
                    'zoom'  => '1',
                },
            },
        );

    $output = $preparer_with->output_as_string( @structure );
    ok( $output eq $css )
        or say "zoom:1 with hacks was:\n" . $output;
    $output = $preparer_without->output_as_string( @structure );
    ok( $output eq $css )
        or say "zoom:1 hack without hacks was:\n" . $output;
    
    $css = <<CSS;
div {
    zoom:                   1;
}
CSS
    $output = $preparer_with_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "zoom:1 hack without hacks was:\n" . $output;
}

# filters
{
    $css = <<CSS;
div{filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=#ff9999aa,endColorstr=#ff333344);}
CSS
@structure = (
        {
            original  => ' filter: progid:DXImageTransform.Microsoft.gradient(startColorstr=#ff9999aa,endColorstr=#ff333344); ',
            selectors => [ 'div' ],
            errors    => [],
            block     => {
                'filter'  => 'progid:DXImageTransform.Microsoft.gradient(startColorstr=#ff9999aa,endColorstr=#ff333344)',
            },
        },
    );

    $output = $preparer_with->output_as_string( @structure );
    ok( $output eq $css )
        or say "filter with hacks was:\n" . $output;
    $output = $preparer_without->output_as_string( @structure );
    ok( $output eq $css )
        or say "filter without hacks was:\n" . $output;
    
    $css = <<CSS;
div {
    filter:                 progid:DXImageTransform.Microsoft.gradient(startColorstr=#ff9999aa,endColorstr=#ff333344);
}
CSS
    $output = $preparer_with_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "filter without hacks was:\n" . $output;
}

# verbatim comments
{
    $css = <<CSS;
/* IE hack */
CSS
    @structure = (
            {
                type => 'verbatim',
                string => "/* IE hack */\n",
            },
        );

    $output = $preparer_with->output_as_string( @structure );
    ok( $output eq $css )
        or say "verbatim with hacks was:\n" . $output;
    $output = $preparer_without->output_as_string( @structure );
    ok( $output eq $css )
        or say "verbatim without hacks was:\n" . $output;
    $output = $preparer_with_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "verbatim without hacks was:\n" . $output;
}

# verbatim blocks
{
    $css = <<CSS;
div {
    blah: 0;
}
CSS
    @structure = (
            {
                type => 'verbatim',
                string => "div {\n    blah: 0;\n}\n",
            },
        );
    
    $output = $preparer_with->output_as_string( @structure );
    ok( $output eq $css )
        or say "verbatim block with hacks was:\n" . $output;
    $output = $preparer_without->output_as_string( @structure );
    ok( $output eq $css )
        or say "verbatim block without hacks was:\n" . $output;
    $output = $preparer_with_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "verbatim block without hacks was:\n" . $output;
}

# chunking boundaries
{
    $css = <<CSS;
li{color:#000;}
h1{color:#000;}
CSS
    @structure = (
            {
                original  => ' color: #000; ',
                selectors => [ 'li' ],
                errors    => [],
                block     => {
                    'color' => '#000',
                },
            },
            { type => 'boundary', },
            {
                original  => ' color: #000; ',
                selectors => [ 'h1' ],
                errors    => [],
                block     => {
                    'color' => '#000',
                },
            },
        );
    
    $output = $preparer_with->output_as_string( @structure );
    ok( $output eq $css )
        or say "chunked content was:\n" . $output;
    $output = $preparer_without->output_as_string( @structure );
    ok( $output eq $css )
        or say "chunked content without hacks was:\n" . $output;
    
    $css = <<CSS;
li {
    color:                  #000;
}
h1 {
    color:                  #000;
}
CSS
    $output = $preparer_with_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "chunked content without hacks was:\n" . $output;
}
