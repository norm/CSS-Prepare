package CSS::Prepare::Property::Generated;

use Modern::Perl;
use CSS::Prepare::Property::Expansions;
use CSS::Prepare::Property::Values;



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
                $type =~ s{_}{-}g;
                push @errors, {
                        error => "invalid ${type} property: '${value}'"
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
        my %types = (
                'list-style-type'     => $list_style_type_value,
                'list-style-image'    => $list_style_image_value,
                'list-style-position' => $list_style_position_value,
            );
        
        %canonical = validate_any_order_shorthand( $value, %types );
        
        push @errors, {
                error => "invalid list-style property: '${value}'"
            }
            unless %canonical;
    }
    
    if ( defined $canonical{'list-style-image'} ) {
        $canonical{'list-style-image'} = shorten_url_value(
                $canonical{'list-style-image'},
                $location,
                $self,
            );
    }
    
    return \%canonical, \@errors;
}
sub output {
    my $self  = shift;
    my $block = shift;
    my @output;
    
    my @properties = qw( content  counter-increment  counter-reset );
    foreach my $property ( @properties ) {
        my $value = $block->{ $property };
        
        push @output, sprintf $self->output_format, "${property}:", $value
            if defined $value;
    }
    
    if ( defined $block->{'quotes'} ) {
        my $value = $block->{'quotes'};
        my $quote_pairs = qr{ ( $string_value \s+ $string_value ) \s* }x;
        my @values;
        
        while ( $value =~ s{^ $quote_pairs }{}x ) {
            push @values, $1;
        }
        
        $value = join $self->output_separator, @values;
        
        push @output, sprintf $self->output_format, "quotes:", $value;
    }
    
    my @list_properties = qw(
            list-style-type  list-style-image  list-style-position
        );
    my @values;
    my @list;
    foreach my $property ( @list_properties ) {
        my $value = $block->{ $property };
        
        if ( defined $value ) {
            push @list, sprintf $self->output_format, "${property}:", $value;
            push @values, $value
                if $value;
        }
    }
    
    if ( 3 == scalar @list ) {
        my $value = join $self->output_separator, @values;
        
        push @output, sprintf $self->output_format, 'list-style:', $value;
    }
    else {
        push @output, @list;
    }
    
    return @output;
}

1;
