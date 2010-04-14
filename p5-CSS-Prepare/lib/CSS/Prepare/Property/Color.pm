package CSS::Prepare::Property::Color;

use Modern::Perl;
use CSS::Prepare::Property::Expansions;
use CSS::Prepare::Property::Values;



sub parse {
    my $self        = shift;
    my $has_hack    = shift;
    my %declaration = @_;
    
    my $property = $declaration{'property'};
    my $value    = $declaration{'value'};
    my %canonical;
    my @errors;
    
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
    my $self  = shift;
    my $block = shift;
    
    my @output;
    my $value = shorten_colour_value( $block->{'color'} );
    push @output, sprintf $self->output_format, 'color:', $value
        if defined $value;
    
    return @output;
}

1;
