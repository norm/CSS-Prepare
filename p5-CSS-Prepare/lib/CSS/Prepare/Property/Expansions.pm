package CSS::Prepare::Property::Expansions;

use Modern::Perl;
use CSS::Prepare::Property::Values;
use Exporter;

our @ISA    = qw( Exporter );
our @EXPORT = qw( expand_trbl_shorthand collapse_trbl_shorthand expand_clip );



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
                $values{ $key } = $values[0];
            }
        }
        when ( 1 ) {
            # top/bottom and left/right shorthand
            foreach my $subproperty qw ( top bottom ) {
                my $key = sprintf $pattern, $subproperty;
                $values{ $key } = $values[0];
            }
            foreach my $subproperty qw ( left right ) {
                my $key = sprintf $pattern, $subproperty;
                $values{ $key } = $values[1];
            }
        }
        when ( 2 ) {
            # top, left/right and bottom shorthand
            my $key = sprintf $pattern, 'top';
            $values{ $key }    = $values[0];
            $key = sprintf $pattern, 'bottom';
            $values{ $key } = $values[2];
            foreach my $subproperty qw ( left right ) {
                $key = sprintf $pattern, $subproperty;
                $values{ $key } = $values[1];
            }
        }
        when ( 3 ) {
            # top, right, bottom and left shorthand
            my $key = sprintf $pattern, 'top';
            $values{ $key } = $values[0];
            $key = sprintf $pattern, 'bottom';
            $values{ $key } = $values[2];
            $key = sprintf $pattern, 'left';
            $values{ $key } = $values[3];
            $key = sprintf $pattern, 'right';
            $values{ $key } = $values[1];
        }
    }
    
    return %values;
}
sub collapse_trbl_shorthand {
    my $property = shift;
    my $block    = shift;
    
    my %values;
    foreach my $direction qw( top right bottom left ) {
        my $value = $block->{"${property}-${direction}"};
        $values{ $value }++;
    }
    
    my $output;
    
    # one value shorthand
    if ( 1 == scalar keys %values ) {
        my( $key, undef ) = each %values;
        $output = "${property}:${key}";
    }
    else {
        my $top          = $block->{"${property}-top"};
        my $right        = $block->{"${property}-right"};
        my $bottom       = $block->{"${property}-bottom"};
        my $left         = $block->{"${property}-left"};
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
    
    return "$output;";
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

1;
