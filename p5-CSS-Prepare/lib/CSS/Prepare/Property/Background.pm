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
        my $shorthand_properties = qr{
                ^
                (?:
                    (?:
                          (?'colour'     $background_colour_value )
                        | (?'image'      $background_image_value )
                        | (?'repeat'     $background_repeat_value )
                        | (?'attachment' $background_attachment_value )
                        | (?'position'   $background_position_value )
                    )
                    \s*
                )+
            }x;
        
        if ( $value  =~ m{$shorthand_properties}x ) {
            my %values = %+;
            
            $canonical{'background-attachment'} = $values{'attachment'} // '';
            $canonical{'background-color'}      = $values{'colour'}     // '';
            $canonical{'background-image'}      = $values{'image'}      // '';
            $canonical{'background-repeat'}     = $values{'repeat'}     // '';
            $canonical{'background-position'}   = $values{'position'}   // '';
        }
        else {
            push @errors, {
                    error => "invalid background property: '${value}'"
                };
        }
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
