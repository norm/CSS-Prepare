package CSS::Prepare::Property::Border;

use Modern::Perl;
use CSS::Prepare::Property::Expansions;
use CSS::Prepare::Property::Values;



sub parse {
    my $self        = shift;
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
    
    my $shorthand_properties = qr{
            ^
            (?:
                (?:
                      (?'style'      $border_style_value  )
                    | (?'width'      $border_width_value  )
                    | (?'colour'     $border_colour_value )
                )
                \s*
            )+
            $
        }x;
    
    foreach my $direction qw( top right bottom left ) {
        &$valid_property_or_error( 'border_colour' )
            if $property =~ m{border-${direction}-colou?r};
        &$valid_property_or_error( 'border_style' )
            if "border-${direction}-style" eq $property;
        &$valid_property_or_error( 'border_width' )
            if "border-${direction}-width" eq $property;
        
        if ( "border-${direction}" eq $property ) {
            if ( $value =~ $shorthand_properties ) {
                my %values = %+;
                
                $canonical{"border-${direction}-color"}
                    = $values{'colour'}  // '';
                $canonical{"border-${direction}-style"}
                    = $values{'style'}  // '';
                $canonical{"border-${direction}-width"}
                    = $values{'width'}  // '';
            }
            else {
                push @errors, {
                        error => "invalid border-${direction} property: "
                                 . $value,
                    };
            }
        }
    }
    
    if ( 'border-color' eq $property || 'border-colour' eq $property ) {
        my $colour_shorthand_properties = qr{
                ^
                (?:
                    $border_colour_value
                    (?: \s+ $border_colour_value )?
                    (?: \s+ $border_colour_value )?
                    (?: \s+ $border_colour_value )?
                )
                $
            }x;
        
        if ( $value =~ $colour_shorthand_properties ) {
            %canonical = expand_trbl_shorthand(
                    'border-%s-color',
                    $value 
                );
        }
        else {
            push @errors, {
                    error => "invalid border-color property: "
                             . $value,
                };
        }
    }
    
    if ( 'border-style' eq $property ) {
        my $style_shorthand_properties = qr{
                ^
                (?:
                    $border_style_value
                    (?: \s+ $border_style_value )?
                    (?: \s+ $border_style_value )?
                    (?: \s+ $border_style_value )?
                )
                $
            }x;
        
        if ( $value =~ $style_shorthand_properties ) {
            %canonical = expand_trbl_shorthand(
                    'border-%s-style',
                    $value 
                );
        }
        else {
            push @errors, {
                    error => "invalid border-style property: "
                             . $value,
                };
        }
    }
    
    if ( 'border-width' eq $property ) {
        my $width_shorthand_properties = qr{
                ^
                (?:
                    $border_width_value
                    (?: \s+ $border_width_value )?
                    (?: \s+ $border_width_value )?
                    (?: \s+ $border_width_value )?
                )
                $
            }x;
        
        if ( $value =~ $width_shorthand_properties ) {
            %canonical = expand_trbl_shorthand(
                    'border-%s-width',
                    $value
                );
        }
        else {
            push @errors, {
                    error => "invalid border-width property: "
                             . $value,
                };
        }
    }
    
    if ( 'border' eq $property ) {
        if ( $value =~ $shorthand_properties ) {
            my %values = %+;
            
            foreach my $direction qw( top right bottom left ) {
                $canonical{"border-${direction}-color"}
                    = $values{'colour'}  // '';
                $canonical{"border-${direction}-style"}
                    = $values{'style'}  // '';
                $canonical{"border-${direction}-width"}
                    = $values{'width'}  // '';
            }
        }
        else {
            push @errors, {
                    error => "invalid border property: ${value}",
                };
        }
    }
    
    return \%canonical, \@errors;
}
sub output {
    my $block = shift;
    
    my( $by_direction, @output_by_direction )
        = output_shorthand_by_direction( $block );
    my( $by_property, @output_by_property )
        = output_shorthand_by_property( $block );
    
    return ( length( $by_property ) < length( $by_direction ) )
            ? @output_by_property
            : @output_by_direction;
}

sub output_shorthand_by_direction {
    my $block = shift;
    
    my @output;
    my %directions;
    my %by_value;
    
    DIRECTION:
    foreach my $direction ( @standard_directions ) {
        my $shorthand;
        
        ASPECT:
        foreach my $aspect qw( width style color ) {
            my $property = "border-${direction}-${aspect}";
            my $value    = $block->{ $property };
            
            next DIRECTION
                unless defined $value;
            
            $shorthand .= " $value"
                if '' ne $value;
        }
        
        $shorthand =~ s{^\s+}{};
        $directions{ $direction } = $shorthand;
        push @{$by_value{ $shorthand }}, $direction;
    }
    
    # if we have all four directions as shorthand, then we can probably
    # create a border shorthand
    if ( 4 == scalar keys %directions ) {
        # if all directions the same, we have a border shorthand
        if ( 1 == scalar keys %by_value ) {
            my( $property, undef ) = each %by_value;
            
            push @output, "border:${property};";
        }
        # if at least two directions are the same, we have a border shorthand
        # that is then overriden by other directions
        elsif ( 4 != scalar keys %by_value ) {
            my $num_children = sub {
                    my $a_children = scalar @{$by_value{ $a }};
                    my $b_children = scalar @{$by_value{ $b }};
                    return $b_children <=> $a_children;
                };
            my @properties = sort $num_children keys %by_value;
            
            my $property = shift @properties;
            push @output, "border:${property};";
            
            foreach $property ( @properties ) {
                foreach my $direction ( @{$by_value{ $property }} ) {
                    push @output, "border-${direction}:${property};";
                }
            }
        }
        # if all four directions different, we have no border shorthand so
        # save the by-direction types to compare against the by-property types
        else {
            foreach my $property ( sort keys %by_value ) {
                my $value = $by_value{ $property };
                push @output, "border-${value}:${property};";
            }
        }
    }
    else {
        foreach my $direction ( @standard_directions ) {
            my $value = $directions{ $direction };
            
            if ( defined $value ) {
                push @output, "border-${direction}:${value};";
            }
            else {
                foreach my $aspect qw( color style width ) {
                    my $property = "border-${direction}-${aspect}";
                    my $value    = $block->{ $property };
                    
                    push @output, "${property}:${value};"
                        if defined $value;
                }
            }
        }
    }
    
    my $output = join '', @output;
    return( $output, @output );
}

sub output_shorthand_by_property {
    my $block = shift;
    
    my @output;
    my %properties;
    
    ASPECT:
    foreach my $aspect qw( color style width ) {
        my @properties;
        
        DIRECTION:
        foreach my $direction ( @standard_directions ) {
            my $property = "border-${direction}-${aspect}";
            my $value    = $block->{ $property };
            
            push @properties, "${property}:$value;"
                if defined $value;
        }
        
        if ( 4 == scalar @properties ) {
            push @output,
                collapse_trbl_shorthand(
                    "border-%s-${aspect}", "border-${aspect}", $block
                );
        }
        else {
            push @output, @properties;
        }
    }
    
    my $output = join '', @output;
    return( $output, @output );
}

1;
