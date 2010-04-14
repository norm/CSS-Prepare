use Modern::Perl;
use Test::More  tests => 12;

use CSS::Prepare;

my $preparer_concise = CSS::Prepare->new();
my $preparer_pretty  = CSS::Prepare->new( pretty => 1 );
my( $css, @structure, $output );


# check properties
{
    @structure = (
            {
                selectors => [ 'caption' ],
                block     => {
                    'caption-side' => 'top',
                },
            },
        );
    $css = <<CSS;
caption{caption-side:top;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "caption-side was:\n" . $output;
    $css = <<CSS;
caption {
    caption-side:           top;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "caption-side was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'table' ],
                block     => {
                    'table-layout' => 'auto',
                },
            },
        );
    $css = <<CSS;
table{table-layout:auto;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "table-layout was:\n" . $output;
    $css = <<CSS;
table {
    table-layout:           auto;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "table-layout was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'table' ],
                block     => {
                    'border-collapse' => 'separate',
                },
            },
        );
    $css = <<CSS;
table{border-collapse:separate;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "border-collapse was:\n" . $output;
    $css = <<CSS;
table {
    border-collapse:        separate;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "border-collapse was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'table' ],
                block     => {
                    'important-border-collapse' => 'separate',
                },
            },
        );
    $css = <<CSS;
table{border-collapse:separate !important;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "border-collapse was:\n" . $output;
    $css = <<CSS;
table {
    border-collapse:        separate
                            !important;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "border-collapse was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'table' ],
                block     => {
                    'border-spacing' => '2px 0',
                },
            },
        );
    $css = <<CSS;
table{border-spacing:2px 0;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "border-spacing was:\n" . $output;
    $css = <<CSS;
table {
    border-spacing:         2px 0;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "border-spacing was:\n" . $output;
}
{
    @structure = (
            {
                selectors => [ 'table' ],
                block     => {
                    'empty-cells' => 'hide',
                },
            },
        );
    $css = <<CSS;
table{empty-cells:hide;}
CSS

    $output = $preparer_concise->output_as_string( @structure );
    ok( $output eq $css )
        or say "empty-cells was:\n" . $output;
    $css = <<CSS;
table {
    empty-cells:            hide;
}
CSS

    $output = $preparer_pretty->output_as_string( @structure );
    ok( $output eq $css )
        or say "empty-cells was:\n" . $output;
}
