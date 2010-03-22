package CSS::Prepare::Property::Generated;

use Modern::Perl;
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
                        error => "invalid ${type} property: ${value}"
                    };
            }
            return $is_valid;
        };
    
    foreach my $type qw( content  quotes ) {
        &$valid_property_or_error( $type )
            if $type eq $property;
    }

    &$valid_property_or_error( 'counter_increment' )
        if 'counter-increment' eq $property;
    
    &$valid_property_or_error( 'counter_reset' )
        if 'counter-reset' eq $property;
    
    &$valid_property_or_error( 'list_style_type' )
        if 'list-style-type' eq $property;
    
    &$valid_property_or_error( 'list_style_image' )
        if 'list-style-image' eq $property;
    
    &$valid_property_or_error( 'list_style_position' )
        if 'list-style-position' eq $property;
    
    if ( 'list-style' eq $property ) {
        %canonical = expand_list_style( $value );
        
        push @errors, {
                error => "invalid list-style property: $value"
            }
            if !%canonical;
    }
    
    return \%canonical, \@errors;
}
sub output {
    my $block = shift;
    my @output;
    
    my @properties = qw( content  counter-increment  counter-reset  quotes );
    foreach my $property ( @properties ) {
        my $value = $block->{ $property };
        
        push @output, "$property:$value;"
            if defined $value;
    }
    
    my @list_properties = qw(
            list-style-type  list-style-image  list-style-position
        );
    my $list_shorthand;
    my @list;
    foreach my $property ( @list_properties ) {
        my $value = $block->{ $property };
        
        if ( defined $value ) {
            push @list, "${property}:${value};";
            $list_shorthand .= " $value"
                if $value;
        }
    }
    
    if ( 3 == scalar @list ) {
        $list_shorthand =~ s{^\s+}{};
        push @output, "list-style:${list_shorthand};"
    }
    else {
        push @output, @list;
    }
    
    return @output;
}

sub expand_list_style {
    my $value = shift;
    
    my $list_style = qr{
            ^ \s*
            ( 
                  $list_style_type_value
                | $list_style_image_value
                | $list_style_position_value
            )
        }x;
    
    my %values = (
            'list-style-type'     => '',
            'list-style-image'    => '',
            'list-style-position' => '',
        );
    
    VALUE:
    while ( $value =~ s{$list_style}{}x ) {
        my $part = $1;
        
        my $is_type = $part =~ m{$list_style_type_value} 
                      && !$values{'list-style-type'};
        if ( $is_type ) {
            $values{'list-style-type'} = $part;
            next VALUE;
        }
        
        my $is_image = $part =~ m{$list_style_image_value} 
                       && !$values{'list-style-image'};
        if ( $is_image ) {
            $values{'list-style-image'} = $part;
            next VALUE;
        }
        
        my $is_position = $part =~ m{$list_style_position_value} 
                          && !$values{'list-style-position'};
        if ( $is_position ) {
            $values{'list-style-position'} = $part;
            next VALUE;
        }
        
        # error
        return;
    }
    
    return if 'none' eq $values{'list-style-type'}
           && 'none' eq $values{'list-style-image'};
    
    return %values;
}

1;
