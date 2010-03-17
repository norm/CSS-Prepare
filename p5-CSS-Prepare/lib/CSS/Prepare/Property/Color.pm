package CSS::Prepare::Property::Color;

use Modern::Perl;
use CSS::Prepare::Property::Expansions;
use CSS::Prepare::Property::Values;



sub parse {
    my %declaration = @_;
    
    my $property = $declaration{'property'};
    my $value    = $declaration{'value'};
    my %canonical;
    my @errors;
    
    # TODO - use regexps now for validation of values
    # allow for the correct spelling of colour
    if ( $property =~ m{^ colo u? r $}x ) {
        if ( is_colour_value( $value ) ) {
            %canonical = ( 'color' => $value );
        }
        else {
            push @errors, {
                    error => "invalid color value '$value'",
                };
        }
    }
    
    return \%canonical, \@errors;
}
sub output {
    my $block = shift;
    
    my @output;
    if ( defined $block->{'color'} ) {
        my $value = $block->{'color'};
        
        $value = shorten_colour_value( $value );
        
        push @output, "color:${value};";
    }
    
    return @output;
}

1;
