package CSS::Prepare::Property::Effects;

use Modern::Perl;
use CSS::Prepare::Property::Values;
use CSS::Prepare::Property::Expansions;



sub parse {
    my $self        = shift;
    my $has_hack    = shift;
    my $location    = shift;
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
                        error => "invalid ${type} property: '${value}'"
                    };
            }
            return $is_valid;
        };
    
    foreach my $type qw( overflow visibility ) {
        &$valid_property_or_error( $type )
            if $type eq $property;
    }
    
    if ( $property eq 'clip' ) {
        %canonical = expand_clip( $value )
            if &$valid_property_or_error( 'clip' );
    }
    
    return \%canonical, \@errors;
}
sub output {
    my $self  = shift;
    my $block = shift;
    my @output;
    
    foreach my $property ( qw( overflow  visibility ) ) {
        my $value = $block->{ $property };
        
        push @output, sprintf $self->output_format, "${property}:", $value
            if defined $value;
    }
    
    my @values;
    foreach my $direction ( qw( top right bottom left ) ) {
        my $property = "clip-rect-${direction}";
        my $value    = $block->{ $property };
        
        push @values, $value
            if defined $value;
    }
    if ( 4 == scalar @values ) {
        my $value;
        
        if ( $self->pretty_output ) {
            my $clip = join ', ', @values;
            $value   = "rect( ${clip} )";
        }
        else {
            my $clip = join ',', @values;
            $value   = "rect(${clip})";
        }
        push @output, sprintf $self->output_format, "clip:", $value;
    }
    
    return @output;
}

1;
