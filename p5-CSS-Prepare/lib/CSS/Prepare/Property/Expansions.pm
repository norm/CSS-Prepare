package CSS::Prepare::Property::Expansions;

use Modern::Perl;
use CSS::Prepare::Property::Values;
use Exporter;

our @ISA    = qw( Exporter );
our @EXPORT = qw(
        expand_trbl_shorthand
        collapse_trbl_shorthand
        expand_clip
        shorten_colour_value
        shorten_length_value
        shorten_url_value
        validate_any_order_shorthand
        get_corner_values
        expand_corner_values
        collapse_corner_values
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
    my $block    = shift;
    
    my %values;
    foreach my $direction qw( top right bottom left ) {
        my $key   = sprintf $pattern, $direction;
        my $value = $block->{ $key };
        $values{ $value }++;
    }
    
    my @values;
    my $key          = sprintf $pattern, 'top';
    my $top          = $block->{ $key };
       $key          = sprintf $pattern, 'right';
    my $right        = $block->{ $key };
       $key          = sprintf $pattern, 'bottom';
    my $bottom       = $block->{ $key };
       $key          = sprintf $pattern, 'left';
    my $left         = $block->{ $key };
    my $two_values   = $top  ne $right;
    my $three_values = $top  ne $bottom;
    my $four_values  = $left ne $right;
    
    push @values, $top;
    push @values, $right
        if $two_values or $three_values or $four_values;
    push @values, $bottom
        if $three_values or $four_values;
    push @values, $left
        if $four_values;
    
    my $value  = join ' ', @values;
    
    return( $value, scalar keys %values );
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
sub shorten_url_value {
    my $value    = shift;
    my $location = shift // undef;
    my $self     = shift // undef;
    
    return
        unless defined $value;
    
    # CSS2.1 4.3.4: "The format of a URI value is ’url(’ followed by
    # optional white space followed by an optional single quote (’)
    # or double quote (")..."
    if ( $value =~ m{ (.*) url\( \s* ['"]? (.*?) ['"]? \s* \) (.*) }x ) {
        my $url = $2;
        
        if ( defined $location && defined $self ) {
            $url = $self->copy_file_to_staging( $url, $location )
                if $self->assets_output;
        }
        
        $value = "${1}url($url)${3}";
    }
    
    return $value;
}

sub validate_any_order_shorthand {
    my $value = shift;
    my %types = @_;
    
    # prepare the return value hash
    my %return;
    foreach my $type ( keys %types ) {
        $return{ $type } = '';
    }
    
    my $options_string       = join '|', values %types;
    my $shorthand_option     = qr{ ( $options_string ) \s* }x;
    my $count                = scalar keys %types;
    my $shorthand_properties = qr{ ^ (?: $shorthand_option ){1,$count} $}x;
    
    if ( $value =~ m{$shorthand_properties} ) {
        my %properties;
        
        # pull each property out of the shorthand string
        # and determine which type(s) it is
        while ( $value =~ s{^$shorthand_option}{}x ) {
            my $property = $1;
            foreach my $type ( keys %types ) {
                my $check = $types{ $type };
                $properties{ $property }{ $type } = 1
                    if $property =~ m{^$check$};
            }
        }
        return if length $value;
        
        # sort with the lowest matches first, to ensure properties that could
        # be multiples are resolved correctly eg. in "list-style: none
        # url(dot.gif)" the "none" part is either a list-style-type or
        # list-style-image property, but "url(dot.gif)" can only be a
        # list-style-image property. By removing list-style-image from the
        # available options of "none" first, we make sure that that is
        # correctly resolved as being a list-style-type property.
        my $lowest_children_first = sub {
                my $a_count = scalar keys %{$properties{$a}};
                my $b_count = scalar keys %{$properties{$b}};
                return $a_count <=> $b_count;
            };
        
        my @properties = sort $lowest_children_first keys %properties;
        foreach my $property ( @properties ) {
            # without at least one remaining type, its an invalid shorthand
            my @types = sort keys %{$properties{ $property }};
            my $type  = shift @types;
            return unless defined $type;
            
            # set the type and remove other possibilities
            $return { $type } = $property;
            delete $properties{ $property };
            
            my @others = keys %properties;
            foreach my $property ( @others ) {
                delete $properties{ $property }{ $type };
                delete $properties{ $property } 
                    unless scalar keys %{$properties{ $property }};
            }
        }
        
        # if anything remains unallocated to a property, then we have an
        # invalid shorthand
        return if scalar keys %properties;
    }
    
    return %return;
}

sub get_corner_values {
    my $block = shift;
    my $type  = shift // 'css3';
    
    my @horizontal;
    my @vertical;
    
    my $get_border_radius_corner_value = qr{
            ( $individual_border_radius_value )
            (?: \s+ ( $individual_border_radius_value ) )?
        }x;
    
    foreach my $corner ( @standard_corners ) {
        my $moz_corner  = $corner;
           $moz_corner =~ s{-}{};
        
        my $key =   'css3' eq $type ? "border-${corner}-radius"
                  : 'moz'  eq $type ? "-moz-border-radius-${moz_corner}"
                                    : "-webkit-border-${corner}-radius";
        my $value = $block->{ $key };
        
        $value =~ m{ $get_border_radius_corner_value }x;
        push @horizontal, $1;
        push @vertical, $2;
    }
    
    return( \@horizontal, \@vertical );
}
sub expand_corner_values {
    my @values = @_;
    
    my @return;
    if ( 1 == scalar @values ) {
        push @return, $values[0];
        push @return, $values[0];
        push @return, $values[0];
        push @return, $values[0];
    }
    elsif ( 2 == scalar @values ) {
        push @return, $values[0];
        push @return, $values[1];
        push @return, $values[0];
        push @return, $values[1];
    }
    elsif ( 3 == scalar @values ) {
        push @return, $values[0];
        push @return, $values[1];
        push @return, $values[2];
        push @return, $values[1];
    }
    else   {
        push @return, @values;
    }
    
    return @return;
}
sub collapse_corner_values {
    my $top_left     = shift // '';
    my $top_right    = shift // '';
    my $bottom_right = shift // '';
    my $bottom_left  = shift // '';
    
    my $two_values   = $top_left  ne $top_right;
    my $three_values = $top_left  ne $bottom_right;
    my $four_values  = $top_right ne $bottom_left;
    my @values;
    
    push @values, $top_left;
    push @values, $top_right
        if $two_values or $three_values or $four_values;
    push @values, $bottom_right
        if $three_values or $four_values;
    push @values, $bottom_left
        if $four_values;
    
    return join ' ', @values;
}

1;
