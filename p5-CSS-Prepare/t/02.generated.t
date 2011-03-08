use Modern::Perl;
use Test::More  tests => 18;

use CSS::Prepare;
use Data::Dumper;
local $Data::Dumper::Terse     = 1;
local $Data::Dumper::Indent    = 1;
local $Data::Dumper::Useqq     = 1;
local $Data::Dumper::Deparse   = 1;
local $Data::Dumper::Quotekeys = 0;
local $Data::Dumper::Sortkeys  = 1;

my $preparer = CSS::Prepare->new();
my( $css, @structure, @parsed );


# simple identifiers in counters work
{
    $css = <<CSS;
        div { counter-increment: section; }
        ol { counter-reset: list; }
CSS
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
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "counter with identifier was:\n" . Dumper \@parsed;
}

# identifiers with value in counters work
{
    $css = <<CSS;
        div { counter-increment: section 2; }
        ol { counter-reset: list 1; }
CSS
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
                original  => ' counter-reset: list 1; ',
                errors    => [],
                selectors => [ 'ol' ],
                block     => { 
                    'counter-reset' => 'list 1', 
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "counter with identifier and value was:\n" . Dumper \@parsed;
}

# multiple identifiers with optional value in counters work
{
    $css = <<CSS;
        div { counter-increment: misc section 2; }
        ol { counter-reset: list 1 lists 0; }
CSS
    @structure = (
            {
                original  => ' counter-increment: misc section 2; ',
                errors    => [],
                selectors => [ 'div' ],
                block     => { 
                    'counter-increment' => 'misc section 2', 
                },
            },
            {
                original  => ' counter-reset: list 1 lists 0; ',
                errors    => [],
                selectors => [ 'ol' ],
                block     => { 
                    'counter-reset' => 'list 1 lists 0', 
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "counter with multiple values was:\n" . Dumper \@parsed;
}

# quotes property works
{
    $css = <<CSS;
        q { quotes: '“' '”'; }
CSS
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
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "quotes was:\n" . Dumper \@parsed;
}

# multiple quotes property works
{
    $css = <<CSS;
        q { quotes: '“' '”' "'" "'"; }
CSS
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
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "multiple quotes was:\n" . Dumper \@parsed;
}

# unmatched pairs of quotes does not work
{
    $css = <<CSS;
        q { quotes: '“' '”' "'"; }
CSS
    @structure = (
            {
                original  => q( quotes: '“' '”' "'"; ),
                errors    => [
                    {
                        error => qq(invalid quotes property: ''“' '”' "'"'),
                    }
                ],
                selectors => [ 'q' ],
                block     => {},
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "unmatched pairs of quotes was:\n" . Dumper \@parsed;
}

# content works
{
    $css = <<CSS;
        blockquote:before { content: "“"; }
CSS
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
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "content was:\n" . Dumper \@parsed;
}

# important
{
    $css = <<CSS;
        blockquote:before { content: "«" !important; }
CSS
    @structure = (
            {
                original  => q( content: "«" !important; ),
                errors    => [],
                selectors => [ 'blockquote:before' ],
                block     => {
                    'important-content' => q("«"),
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "important content was:\n" . Dumper \@parsed;
}

# individual list styles properties work
{
    $css = <<CSS;
        li { list-style-type: armenian; }
CSS
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
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "list-style-type was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        li { list-style-image: url( "dot.gif" ); }
CSS
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
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "list-style-image was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        li { list-style-position: outside; }
CSS
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
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "list-style-position was:\n" . Dumper \@parsed;
}

# list-style shorthand works
{
    $css = <<CSS;
        li { list-style: disc url( 'dot.gif' ) inside; }
CSS
    @structure = (
            {
                original  => q( list-style: disc url( 'dot.gif' ) inside; ),
                errors    => [],
                selectors => [ 'li' ],
                block     => { 
                    'list-style-type'     => 'disc', 
                    'list-style-image'    => 'url(dot.gif)', 
                    'list-style-position' => 'inside', 
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "list-style shorthand was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        li { list-style: inside lower-alpha; }
CSS
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
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "list-style shorthand was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        li { list-style: outside; }
CSS
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
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "list-style shorthand was:\n" . Dumper \@parsed;
}

# "list-style: none" works as described in CSS2.1 12.5.1
{
    $css = <<CSS;
        li { list-style: none; }
CSS
    @structure = (
            {
                original  => ' list-style: none; ',
                errors    => [],
                selectors => [ 'li' ],
                block     => { 
                    'list-style-type'     => '',
                    'list-style-image'    => 'none',
                    'list-style-position' => '',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "list-style none shorthand was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        li { list-style: disc none; }
CSS
    @structure = (
            {
                original  => ' list-style: disc none; ',
                errors    => [],
                selectors => [ 'li' ],
                block     => {
                    'list-style-type'     => 'disc',
                    'list-style-image'    => 'none',
                    'list-style-position' => '',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "list-style image none shorthand was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        li { list-style: url(  dot.gif  ) none; }
CSS
    @structure = (
            {
                original  => ' list-style: url(  dot.gif  ) none; ',
                errors    => [],
                selectors => [ 'li' ],
                block     => {
                    'list-style-type'     => 'none',
                    'list-style-image'    => 'url(dot.gif)',
                    'list-style-position' => '',
                },
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "list-style type none shorthand was:\n" . Dumper \@parsed;
}
{
    $css = <<CSS;
        li { list-style: disc url(dot.gif) none; }
CSS
    @structure = (
            {
                original  => ' list-style: disc url(dot.gif) none; ',
                errors    => [
                    {
                        error => q(invalid list-style property: )
                                 . q('disc url(dot.gif) none'),
                    }
                ],
                selectors => [ 'li' ],
                block     => {},
            },
        );
    
    @parsed = $preparer->parse_string( $css );
    is_deeply( \@structure, \@parsed )
        or say "list-style invalid shorthand was:\n" . Dumper \@parsed;
}
