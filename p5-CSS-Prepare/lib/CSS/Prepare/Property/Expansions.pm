package CSS::Prepare::Property::Expansions;

use Modern::Perl;
use CSS::Prepare::Property::Values;
use Exporter;

our @ISA    = qw( Exporter );
our @EXPORT = qw( expand_trbl_shorthand  collapse_trbl_shorthand
                  expand_clip            shorten_colour_value
                  shorten_length_value
              );



sub expand_trbl_shorthand {
    my $pattern = shift;
    my $value   = shift;
    
    my @values = split( m{\s+}, $value );
    my %values;
    
    given ( $#values ) {
        when ( 0 ) {
            # top/bottom/left/right shorthand
            foreach my $subproperty qw( top bottom left right ) {
                my $key = sprintf $pattern, $subproperty;
                $values{ $key } = shorten_length_value( $values[0] );
            }
        }
        when ( 1 ) {
            # top/bottom and left/right shorthand
            foreach my $subproperty qw ( top bottom ) {
                my $key = sprintf $pattern, $subproperty;
                $values{ $key } = shorten_length_value( $values[0] );
            }
            foreach my $subproperty qw ( left right ) {
                my $key = sprintf $pattern, $subproperty;
                $values{ $key } = shorten_length_value( $values[1] );
            }
        }
        when ( 2 ) {
            # top, left/right and bottom shorthand
            my $key = sprintf $pattern, 'top';
            $values{ $key } = shorten_length_value( $values[0] );
            foreach my $subproperty qw ( left right ) {
                $key = sprintf $pattern, $subproperty;
                $values{ $key } = shorten_length_value( $values[1] );
            }
            $key = sprintf $pattern, 'bottom';
            $values{ $key } = shorten_length_value( $values[2] );
        }
        when ( 3 ) {
            # top, right, bottom and left shorthand
            my $key = sprintf $pattern, 'top';
            $values{ $key } = shorten_length_value( $values[0] );
            $key = sprintf $pattern, 'right';
            $values{ $key } = shorten_length_value( $values[1] );
            $key = sprintf $pattern, 'bottom';
            $values{ $key } = shorten_length_value( $values[2] );
            $key = sprintf $pattern, 'left';
            $values{ $key } = shorten_length_value( $values[3] );
        }
    }
    
    return %values;
}
sub collapse_trbl_shorthand {
    my $pattern  = shift;
    my $property = shift;
    my $block    = shift;
    
    my %values;
    foreach my $direction qw( top right bottom left ) {
        my $key   = sprintf $pattern, $direction;
        my $value = $block->{ $key };
        $values{ $value }++;
    }
    
    my $output;
    
    # one value shorthand
    if ( 1 == scalar keys %values ) {
        my( $key, undef ) = each %values;
        $output = "${property}:${key}";
    }
    else {
        my $key          = sprintf $pattern, 'top';
        my $top          = $block->{ $key };
           $key          = sprintf $pattern, 'right';
        my $right        = $block->{ $key };
           $key          = sprintf $pattern, 'bottom';
        my $bottom       = $block->{ $key };
           $key          = sprintf $pattern, 'left';
        my $left         = $block->{ $key };
        my $three_values = $top  ne $bottom;
        my $four_values  = $left ne $right;
        
        # two value shorthand
        $output = "${property}:${top} ${right}";
        
        if ( $three_values or $four_values ) {
            $output .= " $bottom";
            
            if ( $four_values ) {
                $output .= " $left"
            }
        }
    }
    # four value shorthand
    
    return( "$output;", scalar keys %values );
}

sub expand_clip {
    my $value = shift;
    
    my %values;
    my $get_clip_values = qr{
            ^
                rect \( \s*
                    ( $length_value | auto ) \s* \, \s*
                    ( $length_value | auto ) \s* \, \s*
                    ( $length_value | auto ) \s* \, \s*
                    ( $length_value | auto ) \s*
                \)
            $
        }x;
    
    if ( $value =~ $get_clip_values ) {
        $values{'clip-rect-top'}    = $1;
        $values{'clip-rect-right'}  = $2;
        $values{'clip-rect-bottom'} = $3;
        $values{'clip-rect-left'}   = $4;
    }
    
    return %values;
}

sub shorten_colour_value {
    my $value = shift;
    
    return unless defined $value;
    
    # try to collapse to shortest value
    $value = colour_rgb_to_hex( $value );
    $value = colour_shorten_hex( $value );
    $value = colour_keyword_to_hex( $value );
    $value = colour_hex_to_keyword( $value );
    
    $value = lc $value;
    
    return $value;
}
sub colour_keyword_to_hex {
    my $value = shift;
    
    my %keywords = (
            yellow  => '#ff0',
            fuchsia => '#f0f',
            white   => '#fff',
            black   => '#000',
        );
    if ( defined $keywords{ $value } ) {
        return $keywords{ $value };
    }
    
    return $value;
}
sub colour_hex_to_keyword {
    my $value = shift;
    
    my %values = (
            '#800000' => 'maroon',
            '#f00'    => 'red',
            '#ffa500' => 'orange',
            '#808000' => 'olive',
            '#800080' => 'purple',
            '#008000' => 'green',
            '#000080' => 'navy',
            '#008080' => 'teal',
            '#c0c0c0' => 'silver',
            '#808080' => 'gray',
        );
    if ( defined $values{ $value } ) {
        return $values{ $value };
    }
    
    return $value;
}
sub colour_shorten_hex {
    my $value = shift;
    
    if ( $value =~ m{^ \# (.)\1 (.)\2 (.)\3 }x ) {
        $value = "#$1$2$3";
    }
    
    return $value;
}
sub colour_rgb_to_hex {
    my $value = shift;
    
    my $extract_rgb_values = qr{
            ^ rgb\( \s*
                (\w+)(%?) \, \s*
                (\w+)(%?) \, \s*
                (\w+)(%?)
        }x;
    if ( $value =~ $extract_rgb_values ) {
        my $red   = $1;
        my $green = $3;
        my $blue  = $5;
        
        $red = ( $red * 255 ) / 100
            if $4;
        $green = ( $green * 255 ) / 100
            if $5;
        $blue = ( $blue * 255 ) / 100
            if $6;
        
        $value = sprintf '#%02x%02x%02x', $red, $green, $blue;
    }
    
    return $value;
}

sub shorten_length_value {
    my $value = shift;
    
    $value = '0'
        if $value =~ m{^0([ceimnptx]{2})};
    
    return $value;
}

1;
