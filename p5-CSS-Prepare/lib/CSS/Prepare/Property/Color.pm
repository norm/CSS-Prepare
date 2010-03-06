package CSS::Prepare::Property::Color;

use Modern::Perl;
use CSS::Prepare::Property::Expansions;



sub parse {
    my %declaration = @_;
    
    my $property = $declaration{'property'};
    my $value    = $declaration{'value'};
    my %canonical;
    
    # allow for the correct spelling of colour
    if ( $property =~ m{^ colo u? r $}x ) {
        %canonical = ( 'color' => $value );
    }
    
    return %canonical;
}

1;
