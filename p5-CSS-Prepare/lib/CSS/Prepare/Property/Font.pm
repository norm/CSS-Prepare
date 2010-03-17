package CSS::Prepare::Property::Font;

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
    
    &$valid_property_or_error( 'font_style' )
        if 'font-style' eq $property;
    
    &$valid_property_or_error( 'font_variant' )
        if 'font-variant' eq $property;
    
    &$valid_property_or_error( 'font_weight' )
        if 'font-weight' eq $property;
    
    &$valid_property_or_error( 'font_size' )
        if 'font-size' eq $property;
    
    &$valid_property_or_error( 'font_family' )
        if 'font-family' eq $property;
    
    if ( 'font' eq $property ) {
        my $shorthand_properties = qr{
                ^
                (?: (?'style'       $font_style_value ) \s+ )?
                (?: (?'variant'     $font_variant_value ) \s+ )?
                (?: (?'weight'      $font_weight_value ) \s+ )?
                (?:
                    (?'size'        $font_size_value )
                    (?: /
                        (?'height'  $line_height_value )
                    )?
                    \s+
                )?
                (?: (?'family'      $font_family_value ) )?
                $
            }x;
        
        if ( $value =~ m{$shorthand_properties}x ) {
            my %values = %+;

            $canonical{'font-style'} = $values{'style'}
                if defined $values{'style'};
            $canonical{'font-variant'} = $values{'variant'}
                if defined $values{'variant'};
            $canonical{'font-weight'} = $values{'weight'}
                if defined $values{'weight'};
            $canonical{'font-size'} = $values{'size'}
                if defined $values{'size'};
            $canonical{'line-height'} = $values{'height'}
                if defined $values{'height'};
            $canonical{'font-family'} = $values{'family'}
                if defined $values{'family'};
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
    
    # line-height can be rolled up into a font shorthand
    my @font_properties = qw(
            font-style  font-variant  font-weight
            font-size   line-height   font-family
       );
    my $font_shorthand  = '';
    my $has_line_height = 0;
    my $has_font_size   = 0;
    my @font_styles;
    my @output;
    
    foreach my $property ( @font_properties ) {
        my $value = $block->{ $property };
        
        if ( defined $value ) {
            push @font_styles, "${property}:${value};";
            
            if ( $value ) {
                $has_font_size = 1
                    if 'font-size' eq $property;
                
                if ( 'line-height' eq $property ) {
                    if ( $has_font_size ) {
                        $has_line_height = 1;
                        $font_shorthand .= "/$value";
                    }
                }
                else {
                    $font_shorthand .= " $value";
                }
            }
        }
    }
    
    my $can_shorthand = ( 6 == scalar @font_styles )
                             || ( 5 == @font_styles && !$has_line_height );
    if ( $can_shorthand ) {
        $font_shorthand =~ s{^\s+}{};
        push @output, "font:${font_shorthand};";
        push @output, "line-height:$block->{'line-height'};"
            if !$has_font_size;
    }
    elsif ( scalar @font_styles ) {
        push @output, @font_styles;
    }
    
    return @output;
}

1;
