package CSS::Prepare::Property::Border;

use Modern::Perl;
use CSS::Prepare::Property::Expansions;
use CSS::Prepare::Property::Values;



sub parse {
    my %declaration = @_;
    
    my $property = $declaration{'property'};
    my $value    = $declaration{'value'};
    my %canonical;
    
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
    
    return %canonical;
}

sub expand_border_shorthand {
    my $side  = shift;
    my $value = shift;
    
    my @values = split ( m{\s+}, $value );
    my %values;
    
    given ( $#values ) {
        when ( 0 ) {
            # this produces a border
            if ( is_border_style_value( $value ) ) {
                $values{"border-${side}-width"} = '';
                $values{"border-${side}-style"} = $value;
                $values{"border-${side}-color"} = '';
            }
            
            # these do not (TODO emit warning)
            elsif ( is_colour_value( $value ) ) {
                $values{"border-${side}-width"} = '';
                $values{"border-${side}-style"} = '';
                $values{"border-${side}-color"} = $value;
            }
            else {
                # not style or color, then width
                $values{"border-${side}-width"} = $value;
                $values{"border-${side}-style"} = '';
                $values{"border-${side}-color"} = '';
            }
        }
        when ( 1 ) {
            my $property1 = is_border_style_value( $values[0] ) ? 'style'
                          : is_colour_value( $values[0] )       ? 'color'
                                                                : 'width';
            my $property2 = is_border_style_value( $values[1] ) ? 'style'
                          : is_colour_value( $values[1] )       ? 'color'
                                                                : 'width';
            my $property3 
                = ('style' ne $property1 && 'style' ne $property2) ? 'style'
                : ('color' ne $property1 && 'color' ne $property2) ? 'color'
                                                                   : 'width';
            
            $values{"border-${side}-${property1}"} = $values[0];
            $values{"border-${side}-${property2}"} = $values[1];
            $values{"border-${side}-${property3}"} = '';
        }
        when ( 2 ) {
            $values{"border-${side}-width"} = $values[0];
            $values{"border-${side}-style"} = $values[1];
            $values{"border-${side}-color"} = $values[2];
        }
    }
    
    return %values;
}


1;
