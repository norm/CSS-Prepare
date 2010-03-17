package CSS::Prepare::Property::Color;

use Modern::Perl;
use CSS::Prepare::Property::Expansions;
use CSS::Prepare::Property::Values;



sub parse {
    my %declaration = @_;
    
    my $property = $declaration{'property'};
    my $value    = $declaration{'value'};
    my %canonical;
    my @errors;
    
    # TODO - use regexps now for validation of values
    # allow for the correct spelling of colour
    if ( $property =~ m{^ colo u? r $}x ) {
        if ( is_colour_value( $value ) ) {
            %canonical = ( 'color' => $value );
        }
        else {
            push @errors, {
                    error => "invalid color value '$value'",
                };
        }
    }
    
    return \%canonical, \@errors;
}
sub output {
    my $block = shift;
    
    my @output;
    if ( defined $block->{'color'} ) {
        my $value = $block->{'color'};
        
        # try to collapse to shortest value
        $value = rgb_to_hex( $value );
        $value = shorten_hex( $value );
        $value = keyword_to_hex( $value );
        $value = hex_to_keyword( $value );
        
        push @output, "color:${value};";
    }
    
    return @output;
}

sub keyword_to_hex {
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
sub hex_to_keyword {
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
sub shorten_hex {
    my $value = shift;
    
    if ( $value =~ m{^ \# (.)\1 (.)\2 (.)\3 }x ) {
        $value = "#$1$2$3";
    }
    
    return $value;
}
sub rgb_to_hex {
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


1;
