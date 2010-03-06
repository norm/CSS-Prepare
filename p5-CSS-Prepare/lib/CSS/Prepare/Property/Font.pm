package CSS::Prepare::Property::Font;

use Modern::Perl;
use CSS::Prepare::Property::Values;



sub parse {
    my %declaration = @_;
    
    my $property = $declaration{'property'};
    my $value    = $declaration{'value'};
    my %canonical;
    
    given ( $property ) {
        when ( 'font-style'   ) { $canonical{ $property } = $value; }
        when ( 'font-variant' ) { $canonical{ $property } = $value; }
        when ( 'font-weight'  ) { $canonical{ $property } = $value; }
        when ( 'font-size'    ) { $canonical{ $property } = $value; }
        when ( 'font-family'  ) { $canonical{ $property } = $value; }
        
        when ( 'font' ) {
            my @partials = split ( m{\s+}, $value );
            
            foreach my $partial ( @partials ) {
                if ( is_font_style_value( $partial ) ) {
                    $canonical{'font-style'} = $partial;
                }
                elsif ( is_font_variant_value( $partial ) ) {
                    $canonical{'font-variant'} = $partial;
                }
                elsif ( is_font_weight_value( $partial ) ) {
                    $canonical{'font-weight'} = $partial;
                }
                elsif ( is_font_size_value( $partial ) ) {
                    $canonical{'font-size'} = $partial;
                }
                else {
                    $canonical{'font-family'} .= "$partial ";
                }
            }
        }
    }
    
    # simple concatenation leaves us with extra space, remove it
    if ( defined $canonical{'font-family'} ) {
        $canonical{'font-family'} =~ s{ \s+ $}{}x;
    }
    
    return %canonical;
}

1;
