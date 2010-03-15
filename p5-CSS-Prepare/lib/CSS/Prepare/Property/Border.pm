package CSS::Prepare::Property::Border;

use Modern::Perl;
use CSS::Prepare::Property::Expansions;
use CSS::Prepare::Property::Values;



sub parse {
    my %declaration = @_;
    
    my $property = $declaration{'property'};
    my $value    = $declaration{'value'};
    my %canonical;
    my @errors;
    
    given ( $property ) {
        
        when ( 'border-width' ) {
            %canonical = expand_trbl_shorthand(
                    'border-%s-width',
                    $value 
                );
        }
        when ( 'border-top-width' )    { $canonical{ $property } = $value; }
        when ( 'border-right-width' )  { $canonical{ $property } = $value; }
        when ( 'border-bottom-width' ) { $canonical{ $property } = $value; }
        when ( 'border-left-width' )   { $canonical{ $property } = $value; }
        
        when ( 'border-color' ) {
            %canonical = expand_trbl_shorthand(
                    'border-%s-color',
                    $value 
                );
        }
        when ( 'border-top-color' )    { $canonical{ $property } = $value; }
        when ( 'border-right-color' )  { $canonical{ $property } = $value; }
        when ( 'border-bottom-color' ) { $canonical{ $property } = $value; }
        when ( 'border-left-color' )   { $canonical{ $property } = $value; }
        
        when ( 'border-style' ) {
            %canonical = expand_trbl_shorthand(
                    'border-%s-style',
                    $value 
                );
        }
        when ( 'border-top-style' )    { $canonical{ $property } = $value; }
        when ( 'border-right-style' )  { $canonical{ $property } = $value; }
        when ( 'border-bottom-style' ) { $canonical{ $property } = $value; }
        when ( 'border-left-style' )   { $canonical{ $property } = $value; }
        
        when ( 'border-top' ) {
            %canonical = expand_border_shorthand( 'top', $value );
        }
        when ( 'border-right' ) {
            %canonical = expand_border_shorthand( 'right', $value );
        }
        when ( 'border-bottom' ) {
            %canonical = expand_border_shorthand( 'bottom', $value );
        }
        when ( 'border-left' ) {
            %canonical = expand_border_shorthand( 'left', $value );
        }
        
        when ( 'border' ) {
             %canonical = (
                    expand_border_shorthand( 'top', $value ),
                    expand_border_shorthand( 'right', $value ),
                    expand_border_shorthand( 'bottom', $value ),
                    expand_border_shorthand( 'left', $value ),
                );
        }
    }
    
    return \%canonical, \@errors;
}
sub output {
    my $block = shift;
    
    my $count = 0;
    my @values;
    my %directions;
    my %properties;
    my $output;
    
    foreach my $direction qw( top right bottom left ) {
        foreach my $aspect qw( width color style ) {
            my $property = "border-${direction}-${aspect}";
            my $value = $block->{ $property };
            
            if ( defined $value ) {
                push @values, $value;
                
                $directions{ $direction }++;
                $properties{ $aspect    }++;
                $count++;
            }
        }
    }
    
    if ( 1 == $count ) {
        my $value = $block->{ $output };
        $output .= ":${value};";
    }
    elsif ( 2 <= $count ) {
        # if the same property only, and only that, can compress down
        if ( 1 == scalar keys %properties ) {
            my( $key, undef ) = each %properties;
            $output = collapse_border_shorthand_property( $key, $block );
        }

        # if the same direction only, and only that, can compress down
        elsif ( 1 == scalar keys %directions ) {
            my( $key, undef ) = each %directions;
            $output = collapse_border_shorthand_direction( $key, $block );
        }
        
        # if multiple properties in multiple directions, might compress down
        else {
            $output = collapse_border_shorthand( $block );
        }
    }
    
    return $output;
}

sub expand_border_shorthand {
    my $side  = shift;
    my $value = shift;
    
    my @values = split ( m{\s+}, $value );
    my %values;
    
    given ( scalar @values ) {
        when ( 1 ) {
            # this produces a border
            if ( is_border_style_value( $value ) ) {
                $values{"border-${side}-width"} = '';
                $values{"border-${side}-style"} = $value;
                $values{"border-${side}-color"} = '';
            }
            
            # these do not (TODO emit warning)
            elsif ( is_border_colour_value( $value ) ) {
                $values{"border-${side}-width"} = '';
                $values{"border-${side}-style"} = '';
                $values{"border-${side}-color"} = $value;
            }
            elsif ( is_border_width_value( $value ) ) {
                $values{"border-${side}-width"} = $value;
                $values{"border-${side}-style"} = '';
                $values{"border-${side}-color"} = '';
            }
            else {
                die;
            }
        }
        when ( 2 ) {
            my $property1
                = is_border_style_value( $values[0] )    ? 'style'
                  : is_border_colour_value( $values[0] ) ? 'color'
                  : is_border_width_value( $values[0] )  ? 'width'
                                                         : 'unknown';
            my $property2
                = is_border_style_value( $values[1] )    ? 'style'
                  : is_border_colour_value( $values[1] ) ? 'color'
                  : is_border_width_value( $values[1] )  ? 'width'
                                                         : 'unknown';
            
            if ( 'unknown' eq $property1 || 'unknown' eq $property2 ) {
                die;
            }
            
            my $property3 
                = ('style' ne $property1 && 'style' ne $property2) ? 'style'
                : ('color' ne $property1 && 'color' ne $property2) ? 'color'
                                                                   : 'width';
            
            $values{"border-${side}-${property1}"} = $values[0];
            $values{"border-${side}-${property2}"} = $values[1];
            $values{"border-${side}-${property3}"} = '';
        }
        when ( 3 ) {
            $values{"border-${side}-width"} = $values[0];
            $values{"border-${side}-style"} = $values[1];
            $values{"border-${side}-color"} = $values[2];
        }
    }
    
    return %values;
}
sub collapse_border_shorthand_property {
    my $key        = shift;
    my $block      = shift;
    my $value_only = shift;
    
    my %values;
    foreach my $direction qw( top right bottom left ) {
        my $value = $block->{"border-${direction}-${key}"};
        $values{ $value }++;
    }
    
    given ( scalar keys %values ) {
        when ( 1 ) {
            return ( $value_only ? '' : "border-${key}:" )
                 . $block->{"border-top-${key}"}
                 . ';';
        }
        when ( 2 ) {
            return ( $value_only ? '' : "border-${key}:" )
                 . $block->{"border-top-${key}"} 
                 . ' ' 
                 . $block->{"border-right-${key}"}
                 . ';';
        }
        when ( 3 ) {
            return ( $value_only ? '' : "border-${key}:" )
                 . $block->{"border-top-${key}"} 
                 . ' ' 
                 . $block->{"border-right-${key}"}
                 . ' ' 
                 . $block->{"border-bottom-${key}"}
                 . ';';
        }
        when ( 4 ) {
            return ( $value_only ? '' : "border-${key}:" )
                 . $block->{"border-top-${key}"} 
                 . ' ' 
                 . $block->{"border-right-${key}"}
                 . ' ' 
                 . $block->{"border-bottom-${key}"}
                 . ' ' 
                 . $block->{"border-left-${key}"}
                 . ';';
        }
    }
}
sub collapse_border_shorthand_direction {
    my $direction  = shift;
    my $block      = shift;
    my $value_only = shift;
    
    my @values;
    foreach my $property qw( width style color ) {
        my $key   = "border-${direction}-${property}";
        my $value = $block->{ $key };
        
        if ( defined $value ) {
            if ( '0' eq $value ) {
                push @values, '0';
            }
            elsif ( $value ) {
                push @values, $block->{ $key };
            }
        }
    }
    
    return ( $value_only ? '' : "border-${direction}:" )
         . join( ' ', @values )
         . ';';
}
sub collapse_border_shorthand {
    my $block = shift;
    
    my %properties;
    foreach my $direction qw( top right bottom left ) {
        my $output 
            = collapse_border_shorthand_direction( $direction, $block, 1 );
        push @{ $properties{ $output } }, $direction;
    }
    
    my $count = scalar keys %properties;
    given ( $count ) {
        when ( 1 ) {
            # it's a complete border shorthand if all directions match
            my( $key, undef ) = each %properties;
            return "border:${key}"
        }
        when ( 2 || 3 ) {
            # one or two directions override the complete border
            my $sort = sub {
                    my $a_count = scalar @{ $properties{ $a } };
                    my $b_count = scalar @{ $properties{ $b } };
                    return $b_count <=> $a_count;
                };
            
            my $first  = 1;
            my $output;
            foreach my $value ( sort $sort keys %properties ) {
                if ( $first ) {
                    $output .= "border:${value}";
                    $first   = 0;
                }
                else {
                    foreach my $direction ( @{ $properties{ $value } } ) {
                        $output .= "border-${direction}:$value";
                    }
                }
            }
            
            return $output;
        }
        when ( 4 ) {
            die;
        }
    }
}

1;
