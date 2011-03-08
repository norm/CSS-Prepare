use Modern::Perl;
use Test::More  tests => 24;

use CSS::Prepare;

my $preparer_concise = CSS::Prepare->new();
my $preparer_pretty  = CSS::Prepare->new( pretty => 1 );
my( $css, @structure, $output );


# simple identifiers in counters work
{
    @structure = (
            {
                original  => ' counter-increment: section; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 
                    'counter-increment' => 'section', 
                },
            },
            {
                original  => ' counter-reset: list; ',
                errors    => [],
                selectors => [ 'ol' ],
                block     => { 
                    'counter-reset' => 'list', 
                },
            },
        );
    $css = <<CSS;
div{counter-increment:section;}
ol{counter-reset:list;}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "counter with identifier was:\n" . $output;
    
    $css = <<CSS;
div {
    counter-increment:      section;
}
ol {
    counter-reset:          list;
}
CSS
    
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "counter with identifier was:\n" . $output;
}
{
    @structure = (
            {
                original  => ' counter-increment: section; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => {
                    'important-counter-increment' => 'section',
                },
            },
            {
                original  => ' counter-reset: list; ',
                errors    => [],
                selectors => [ 'ol' ],
                block     => {
                    'counter-reset' => 'list',
                },
            },
        );
    $css = <<CSS;
div{counter-increment:section !important;}
ol{counter-reset:list;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "counter with identifier was:\n" . $output;
    $css = <<CSS;
div {
    counter-increment:      section
                            !important;
}
ol {
    counter-reset:          list;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "counter with identifier was:\n" . $output;
}

# identifiers with value in counters work
{
    @structure = (
            {
                original  => ' counter-increment: section 2; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 
                    'counter-increment' => 'section 2', 
                },
            },
            {
                original  => ' counter-reset: list; ',
                errors    => [],
                selectors => [ 'ol' ],
                block     => { 
                    'counter-reset' => 'list', 
                },
            },
        );
    $css = <<CSS;
div{counter-increment:section 2;}
ol{counter-reset:list;}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "counter with identifier and value was:\n" . $output;
    
    $css = <<CSS;
div {
    counter-increment:      section 2;
}
ol {
    counter-reset:          list;
}
CSS
    
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "counter with identifier and value was:\n" . $output;
}

# quotes property works
{
    @structure = (
            {
                original  => q( quotes: '“' '”'; ),
                errors    => [],
                selectors => [ 'q' ],
                block     => { 
                    'quotes' => q('“' '”'), 
                },
            },
        );
    $css = <<CSS;
q{quotes:'“' '”';}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "quotes was:\n" . $output;
    
    $css = <<CSS;
q {
    quotes:                 '“' '”';
}
CSS
    
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "quotes was:\n" . $output;
}

# multiple quotes property works
{
    @structure = (
            {
                original  => q( quotes: '“' '”' "'" "'"; ),
                errors    => [],
                selectors => [ 'q' ],
                block     => { 
                    'quotes' => q('“' '”' "'" "'"), 
                },
            },
        );
    $css = <<CSS;
q{quotes:'“' '”' "'" "'";}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "multiple quotes was:\n" . $output;
    $css = <<CSS;
q {
    quotes:                 '“' '”'
                            "'" "'";
}
CSS
    
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "multiple quotes was:\n" . $output;
}

# content works
{
    @structure = (
            {
                original  => q( content: "“"; ),
                errors    => [],
                selectors => [ 'blockquote:before' ],
                block     => { 
                    'content' => q("“"), 
                },
            },
        );
    $css = <<CSS;
blockquote:before{content:"“";}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "content was:\n" . $output;
    $css = <<CSS;
blockquote:before {
    content:                "“";
}
CSS
    
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "content was:\n" . $output;
}

# individual list styles properties work
{
    @structure = (
            {
                original  => ' list-style-type: armenian; ',
                errors    => [],
                selectors => [ 'li' ],
                block     => { 
                    'list-style-type' => 'armenian', 
                },
            },
        );
    $css = <<CSS;
li{list-style-type:armenian;}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "list-style-type was:\n" . $output;
    $css = <<CSS;
li {
    list-style-type:        armenian;
}
CSS
    
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "list-style-type was:\n" . $output;
}
{
    @structure = (
            {
                original  => ' list-style-image: url( "dot.gif" ); ',
                errors    => [],
                selectors => [ 'li' ],
                block     => {
                    'list-style-image' => 'url(dot.gif)',
                },
            },
        );
    $css = <<CSS; 
li{list-style-image:url(dot.gif);}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "list-style-image was:\n" . $output;
    $css = <<CSS;
li {
    list-style-image:       url(dot.gif);
}
CSS
    
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "list-style-image was:\n" . $output;
}
{
    @structure = (
            {
                original  => ' list-style-position: outside; ',
                errors    => [],
                selectors => [ 'li' ],
                block     => { 
                    'list-style-position' => 'outside', 
                },
            },
        );
    $css = <<CSS;
li{list-style-position:outside;}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "list-style-position was:\n" . $output;
    $css = <<CSS;
li {
    list-style-position:    outside;
}
CSS
    
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "list-style-position was:\n" . $output;
}

# list-style shorthand works
{
    @structure = (
            {
                original  => ' list-style: disc url(dot.gif) inside; ',
                errors    => [],
                selectors => [ 'li' ],
                block     => { 
                    'list-style-type'     => 'disc', 
                    'list-style-image'    => 'url(dot.gif)', 
                    'list-style-position' => 'inside', 
                },
            },
        );
    $css = <<CSS;
li{list-style:disc url(dot.gif) inside;}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "list-style shorthand was:\n" . $output;
    
    $css = <<CSS;
li {
    list-style:             disc
                            url(dot.gif)
                            inside;
}
CSS
    
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "list-style shorthand was:\n" . $output;
}
{
    @structure = (
            {
                original  => ' list-style: inside lower-alpha; ',
                errors    => [],
                selectors => [ 'li' ],
                block     => { 
                    'list-style-type'     => 'lower-alpha',
                    'list-style-image'    => '',
                    'list-style-position' => 'inside', 
                },
            },
        );
    $css = <<CSS;
li{list-style:lower-alpha inside;}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "list-style shorthand was:\n" . $output;
    $css = <<CSS;
li {
    list-style:             lower-alpha
                            inside;
}
CSS
    
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "list-style shorthand was:\n" . $output;
}
{
    @structure = (
            {
                original  => ' list-style: outside; ',
                errors    => [],
                selectors => [ 'li' ],
                block     => { 
                    'list-style-type'     => '', 
                    'list-style-image'    => '', 
                    'list-style-position' => 'outside', 
                },
            },
        );
    $css = <<CSS;
li{list-style:outside;}
CSS
    
    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "list-style shorthand was:\n" . $output;
    $css = <<CSS;
li {
    list-style:             outside;
}
CSS
    
    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "list-style shorthand was:\n" . $output;
}
