package CSS::Prepare::Property::Background;

use Modern::Perl;

# use CSS::Prepare::Property::Expansions;
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
            
            $canonical{'background-color'} = $values{'colour'}
                if defined $values{'colour'};
            $canonical{'background-image'} = $values{'image'}
                if defined $values{'image'};
            $canonical{'background-repeat'} = $values{'repeat'}
                if defined $values{'repeat'};
            $canonical{'background-attachment'} = $values{'attachment'}
                if defined $values{'attachment'};
            $canonical{'background-position'} = $values{'position'}
                if defined $values{'position'};
        }
    }
    
    return \%canonical, \@errors;
}

sub output {
    my $block = shift;
    
    my @properties = qw( background-color background-image background-repeat
                         background-attachment background-position );
    my $count = 0;
    my @values;
    my $output;
    
    foreach my $property ( @properties ) {
        if ( defined $block->{ $property } ) {
            push @values, $block->{ $property };
            $output = $property;
            $count++;
        }
    }
    
    if ( 1 == $count ) {
        my $value = $block->{ $output };
        $output .= ":${value};";
    }
    elsif ( 2 <= $count ) {
        my $value = join ' ', @values;
        $output = "background:$value;";
    }
    
    return $output;
}

1;
