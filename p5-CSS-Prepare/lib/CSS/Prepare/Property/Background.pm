package CSS::Prepare::Property::Background;

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
                        error => "invalid ${type} property: '${value}'"
                    };
            }
        };
    
    &$valid_property_or_error( 'background_colour' )
        if 'background-color' eq $property
           || 'background-colour' eq $property;

    &$valid_property_or_error( 'background_image' )
        if 'background-image' eq $property;

    &$valid_property_or_error( 'background_repeat' )
        if 'background-repeat' eq $property;

    &$valid_property_or_error( 'background_attachment' )
        if 'background-attachment' eq $property;

    &$valid_property_or_error( 'background_position' )
        if 'background-position' eq $property;
    
    if ( 'background' eq $property ) {
        my %types = (
                'background-color'      => $background_colour_value,
                'background-image'      => $background_image_value,
                'background-repeat'     => $background_repeat_value,
                'background-attachment' => $background_attachment_value,
                'background-position'   => $background_position_value,
            );
        
        %canonical = validate_any_order_shorthand( $value, %types );
        
        push @errors, {
                error => "invalid background property: '${value}'"
            }
            unless %canonical;
    }
    
    return \%canonical, \@errors;
}

sub output {
    my $block = shift;
    
    my @properties = qw( background-color background-image background-repeat
                         background-attachment background-position );
    my @values;
    my @output;
    my $shorthand;
    
    foreach my $property ( @properties ) {
        my $value = $block->{ $property };
        
        if ( defined $value ) {
            $value = shorten_background_position_value( $value )
                if 'background-position' eq $property;
            $value = shorten_colour_value( $value )
                if 'background-color' eq $property;
                
            push @values, "$property:$value;";
            $shorthand .= " $value"
                if $value;
        }
    }
    
    if ( 5 == scalar @values ) {
        $shorthand =~ s{^\s+}{};
        push @output, "background:$shorthand;";
    }
    else {
        push @output, @values;
    }
    
    return @output;
}

sub shorten_background_position_value {
    my $value = shift;
    
    return unless defined $value;
    
    $value =~ s{(.+) \s+ (?: center | 50\% ) $}{$1}x;
    return $value;
}

1;
