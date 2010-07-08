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
    
    my $valid_property_or_error = sub {
            my $type  = shift;
            
            my $sub      = "is_${type}_value";
            my $is_valid = 0;
            
            eval {
                no strict 'refs';
                $is_valid = &$sub( $value );
            };
            
            if ( $is_valid ) {
                $canonical{ $property } = $value;
            }
            else {
                push @errors, {
                        error => "invalid ${type} value: '${value}'"
                    };
            }
            return $is_valid;
        };
    
    
    
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
    
    &$valid_property_or_error( 'opacity' )
        if 'opacity' eq $property;
    
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
