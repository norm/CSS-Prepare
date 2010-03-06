use Modern::Perl;
use Test::More  tests => 4;

use CSS::Prepare::Property::Expansions;
use Data::Dumper;
local $Data::Dumper::Terse     = 1;
local $Data::Dumper::Indent    = 1;
local $Data::Dumper::Useqq     = 1;
local $Data::Dumper::Deparse   = 1;
local $Data::Dumper::Quotekeys = 0;
local $Data::Dumper::Sortkeys  = 1;

my( %data, %expansion );



# one value trbl expansion
{
    %data = (
            'margin-top'    => '1px',
            'margin-right'  => '1px',
            'margin-bottom' => '1px',
            'margin-left'   => '1px',
        );
    %expansion = expand_trbl_shorthand( 'margin-%s', '1px' );
    is_deeply( \%data, \%expansion )
        or say "one value trbl expansion was:\n" . Dumper \%expansion;
}

# two value trbl expansion
{
    %data = (
            'margin-top'    => '1px',
            'margin-right'  => '2px',
            'margin-bottom' => '1px',
            'margin-left'   => '2px',
        );
    %expansion = expand_trbl_shorthand( 'margin-%s', '1px 2px' );
    is_deeply( \%data, \%expansion )
        or say "two value trbl expansion was:\n" . Dumper \%expansion;
}

# three value trbl expansion
{
    %data = (
            'margin-top'    => '1px',
            'margin-right'  => '2px',
            'margin-bottom' => '3px',
            'margin-left'   => '2px',
        );
    %expansion = expand_trbl_shorthand( 'margin-%s', '1px 2px 3px' );
    is_deeply( \%data, \%expansion )
        or say "three value trbl expansion was:\n" . Dumper \%expansion;
}

# four value trbl expansion
{
    %data = (
            'margin-top'    => '1px',
            'margin-right'  => '2px',
            'margin-bottom' => '3px',
            'margin-left'   => '4px',
        );
    %expansion = expand_trbl_shorthand( 'margin-%s', '1px 2px 3px 4px' );
    is_deeply( \%data, \%expansion )
        or say "four value trbl expansion was:\n" . Dumper \%expansion;
}
