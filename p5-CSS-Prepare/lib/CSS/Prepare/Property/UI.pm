package CSS::Prepare::Property::UI;

use Modern::Perl;
use CSS::Prepare::Property::Values;



sub parse {
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
                        error => "invalid ${type} property: ${value}"
                    };
            }
        };
    
    &$valid_property_or_error( 'cursor' )
        if 'cursor' eq $property;
    
    &$valid_property_or_error( 'outline_width' )
        if 'outline-width' eq $property;
    
    &$valid_property_or_error( 'outline_style' )
        if 'outline-style' eq $property;
    
    &$valid_property_or_error( 'outline_colour' )
        if 'outline-colour' eq $property
           || 'outline-color' eq $property;
    
    if ( 'outline' eq $property ) {
        my $shorthand_properties = qr{
                ^
                    (?:
                        (?:
                              (?'width'  $outline_width_value  )
                            | (?'colour' $outline_colour_value )
                            | (?'style'  $outline_style_value  )
                        )
                        \s*
                    )+
                    (?'left'  )   # break without this, even though
                                  # it captures nothing???
                $
            }x;
        
        if ( $value =~ m{$shorthand_properties}x ) {
            my %values = %+;
            
            $canonical{'outline-style'} = $values{'style'}  // '';
            $canonical{'outline-width'} = $values{'width'}  // '';
            $canonical{'outline-color'} = $values{'colour'} // '';
        }
        else {
            push @errors, {
                    error => "invalid font property: ${value}"
                };
        }
    }
    
    return \%canonical, \@errors;
}
sub output {
    my $block = shift;
    
    my @outline_properties = qw(
            outline-width  outline-style  outline-color
        );
    my $count = 0;
    my $shorthand;
    my $output;
    
    foreach my $property ( @outline_properties ) {
        my $value = $block->{ $property };
        
        if ( defined $value ) {
            $count++;
            
            if ( $value ) {
                $output    .= "$property:$value;";
                $shorthand .= " $value";
            }
        }
    }
    
    if ( 3 == $count ) {
        $shorthand =~ s{^\s+}{};
        $output = "outline:$shorthand;";
    }
    
    $output .= "cursor:$block->{'cursor'};"
        if defined $block->{'cursor'};
    
    return $output;
}

1;
