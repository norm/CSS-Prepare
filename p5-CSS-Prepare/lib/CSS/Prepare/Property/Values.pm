package CSS::Prepare::Property::Values;

use Modern::Perl;
use Exporter;

our @ISA    = qw( Exporter );
our @EXPORT = qw(
        get_value_type
        is_colour_value
        is_distance_value
        is_identifier_value
        is_integer_value
        is_length_value
        is_percentage_value
        is_string_value
        is_url_value
        
        get_property_type
        is_background_attachment_value
        is_background_repeat_value
        is_bidi_value
        is_border_style_value
        is_clear_value
        is_clip_value
        is_content_value
        is_counter_value
        is_direction_value
        is_display_value
        is_float_value
        is_font_size_value
        is_font_style_value
        is_font_variant_value
        is_font_weight_value
        is_lineheight_value
        is_list_style_image_value
        is_list_style_position_value
        is_list_style_type_value
        is_offset_value
        is_overflow_value
        is_position_value
        is_quotes_value
        is_valign_value
        is_visibility_value
        is_zindex_value
        
        expand_clip
        
        $integer_value
        $identifier_value
        $string_value
        $list_style_type_value
        $list_style_image_value
        $list_style_position_value
    );

our $integer_value             = qr{ [+-]? [0-9]+ }x;
our $identifier_value          = qr{ [a-z][a-zA-z0-9_-]* }x;
our $url_value                 = qr{ url \( [^\)]+ \) }x;
our $string_value              = qr{
        (?<quote> ['"] )        # string delimiter
        .*?                     # content of string
        (?<! \\ ) \k{quote}     # first matching quote that is not escaped
    }x;
our $list_style_type_value     = qr{
        (?:
              armenian    | circle      | decimal     | decimal-leading-zero
            | disc        | georgian    | lower-alpha | lower-greek
            | lower-latin | lower-roman | upper-alpha | upper-latin
            | upper-roman
            
            | none | inherit
        )
    }x;
our $list_style_image_value    = qr{ (?: $url_value | none | inherit ) }x;
our $list_style_position_value = qr{ (?: inside | outside | inherit ) }x;


sub get_value_type {
    my $value = shift;
    
    if ( is_colour_value( $value ) ) {
        return 'color';
    }
    elsif ( is_length_value( $value ) ) {
        return 'length';
    }
    elsif ( is_percentage_value( $value ) ) {
        return 'percentage';
    }
    elsif ( is_url_value( $value ) ) {
        return 'url';
    }
    elsif ( is_string_value( $value ) ) {
        return 'string';
    }
}
sub is_colour_value {
    my $value = shift;

    # is RGB in hex
    return 1
        if $value =~ m{^ \# [0-9a-fA-F]{3} $}x;
    return 1
        if $value =~ m{^ \# [0-9a-fA-F]{6} $}x;

    # is RGB in functional
    return 1
        if $value =~ m{^ rgb \( }x;

    # is colour keyword
    my @colours = qw( 
            aqua    black   blue    fuchsia gray    green
            lime    maroon  navy    olive   orange  purple
            red     silver  teal    white   yellow
        );
    foreach my $colour ( @colours ) {
        return 1
            if $colour eq $value;
    }

    return 0;
}
sub is_distance_value {
    my $value = shift;
    
    return is_length_value( $value )
        || is_percentage_value( $value )
        || 'auto' eq $value;
}
sub is_identifier_value {
    my $value = shift;
    
    return $value =~ m{^ $identifier_value $}x;
}
sub is_integer_value {
    my $value = shift;
    
    return $value =~ m{^ $integer_value $}x;
}
sub is_length_value {
    my $value = shift;
    
    return 1
        if $value =~ m{^ [-]? [\d\.]+ (px|em|ex|in|cm|mm|pt|pc)? $}x;
    
    return 0;
}
sub is_percentage_value {
    my $value = shift;
    
    return 1
        if $value =~ m{^ [\d\.]+ % $}x;
    
    return 0;
}
sub is_string_value {
    my $value = shift;
    
    return 1
        if $value =~ m{^ $string_value $}x;
    
    return 0;
}
sub is_url_value {
    my $value = shift;
    
    return 1
        if $value =~ m{^ $url_value $}x;
    
    return 0;
}

sub get_property_type {
    my $value = shift;
    
    if ( is_background_attachment_value( $value ) ) {
        return 'background-attachment';
    }
    elsif ( is_background_repeat_value( $value ) ) {
        return 'background-repeat';
    }
    elsif ( is_border_style_value( $value ) ) {
        return 'border-style';
    }
    elsif ( is_font_size_value( $value ) ) {
        return 'font-size';
    }
    elsif ( is_font_style_value( $value ) ) {
        return 'font-style';
    }
    elsif ( is_font_variant_value( $value ) ) {
        return 'font-variant';
    }
    elsif ( is_font_weight_value( $value ) ) {
        return 'font-weight';
    }
}
sub is_background_attachment_value {
    my $value = shift;
    
    my @attachments = qw( scroll fixed );
    foreach my $attachment ( @attachments ) {
        return 1
            if $attachment eq $value;
    }
    
    return 0;
}
sub is_background_repeat_value {
    my $value = shift;
    
    my @repeats = qw( repeat repeat-x repeat-y no-repeat );
    foreach my $repeat ( @repeats ) {
        return 1
            if $repeat eq $value;
    }
    
    return 0;
}
sub is_bidi_value {
    my $value = shift;
    
    return in_values(
            $value,
            qw( normal  embed  bidi-override )
        );
}
sub is_border_style_value {
    my $value  = shift;
    
    my @styles = qw(
            none    hidden  dotted  dashed  solid
            double  groove  ridge   inset   outset
        );
    foreach my $style ( @styles ) {
        return 1
            if $style eq $value;
    }
    
    return 0;
}
sub is_clear_value {
    my $value = shift;
    
    return in_values(
            $value,
            qw( left  right  both  none )
        );
}
sub is_clip_value {
    my $value = shift;
    
    my %values = CSS::Prepare::Property::Effects::expand_clip( $value );
    return scalar %values;
}
sub is_content_value {
    my $value = shift;
    
    # TODO
    #   -   values are repeatable
    #   -   can be attr
    #   -   can be uri
    #   -   can be counter
    
    return is_string_value( $value )
        || is_url_value( $value )
        || in_values(
                $value,
                qw(
                    close-quote  no-close-quote  no-open-quote
                    none         normal          open-quote
                )
            );
}
sub is_counter_value {
    my $value = shift;
    
    return 1
        if 'none' eq $value;
    return 1
        if 'inherit' eq $value;
    
    my $counter_value = qr{
            ( $identifier_value )           # $1: the ident
            (?:
                \s+ ( $integer_value )      # $2: the integer
            )?
        }x;
    
    while ( $value =~ s{^ \s* $counter_value }{}x ) {
        # nothing to do, values have been validated and stripped already
    }
    
    return 1
        unless length $value;
    
    return 0;
}
sub is_direction_value {
    my $value = shift;
    
    return in_values(
            $value,
            qw( ltr  rtl )
        );
}
sub is_display_value {
    my $value = shift;
    
    return in_values(
            $value,
            qw(
                block               inline              inline-block
                inline-table        list-item           none
                run-in              table               table-caption
                table-cell          table-column        table-column-group
                table-footer-group  table-header-group  table-row
                table-row-group
            )
        );
}
sub is_float_value {
    my $value = shift;
    
    return in_values(
            $value,
            qw( left  right  none )
        );
}
sub is_font_size_value {
    my $value = shift;
    
    return 1
        if $value =~ m{^ \d }x;
    
    return 0;
}
sub is_font_style_value {
    my $value = shift;
    
    my @styles = qw( italic oblique normal );
    foreach my $style ( @styles ) {
        return 1
            if $style eq $value;
    }
    
    return 0;
}
sub is_font_variant_value {
    my $value = shift;
    
    my @variants = qw( small-caps normal );
    foreach my $variant ( @variants ) {
        return 1
            if $variant eq $value;
    }
    
    return 0;
}
sub is_font_weight_value {
    my $value = shift;
    
    my @weights 
        = qw( bold bolder lighter 100 200 300 400 500 600 700 800 900 );
    foreach my $weights ( @weights ) {
        return 1
            if $weights eq $value;
    }
    
    return 0;
}
sub is_lineheight_value {
    my $value = shift;
    
    return $value =~ m{^ \d+ $}x
        || is_length_value( $value )
        || is_percentage_value( $value )
        || 'inherit' eq $value;
}
sub is_list_style_image_value {
    my $value = shift;
    return $value =~ m{$list_style_image_value}x;
}
sub is_list_style_position_value {
    my $value = shift;
    return $value =~ m{$list_style_position_value}x;
}
sub is_list_style_type_value {
    my $value = shift;
    return $value =~ m{$list_style_type_value}x;
}
sub is_offset_value {
    my $value = shift;
    
    return is_distance_value( $value );
}
sub is_overflow_value {
    my $value = shift;
    
    return in_values(
            $value,
            qw( auto  hidden  scroll  visible )
        );
}
sub is_position_value {
    my $value = shift;
    
    return in_values( 
            $value,
            qw( absolute  fixed  relative  static )
        );
}
sub is_quotes_value {
    my $value = shift;
    
    return 1
        if 'none' eq $value;
    return 1
        if 'inherit' eq $value;
    
    my $quotes_value = qr{
            ^
            \s*
            $string_value \s+       # open quote
            $string_value           # close quote
        }x;
    
    while ( $value =~ s{$quotes_value}{}x ) {
        # nothing to do, values have been validated and stripped already
    }
    
    return 1
        unless length $value;
    
    return 0;
}
sub is_valign_value {
    my $value = shift;
    
    return is_length_value( $value )
        || is_percentage_value( $value )
        || in_values(
            $value,
            qw( baseline    sub     super   top
                text-top    middle  bottom  text-bottom )
        );
}
sub is_visibility_value {
    my $value = shift;
    
    return in_values(
            $value,
            qw( collapse  hidden  visible )
        );
}
sub is_zindex_value {
    my $value = shift;
    
    return $value =~ m{^ \d+ $}x
        || 'auto'    eq $value
        || 'inherit' eq $value;
}

sub in_values {
    my $value = shift;
    my @types = @_;
    
    # can always inherit
    push @types, 'inherit';
    
    foreach my $type ( @types ) {
        return 1
            if $type eq $value;
    }
    
    return 0;
}

sub expand_clip {
    my $value = shift;
    
    my %values;
    my $get_clip_values = qr{
            ^
                \s* rect \( \s*
                    ( [ \s \d \. , % aceimnoptux ]+? )
                \s* \) \s*
            $
        }x;
    
    if ( $value =~ $get_clip_values ) {
        my @values  = split ( m{,\s*}, $1 );
        my $correct = 1;
        
        foreach my $part ( @values ) {
            $correct = 0
                unless is_length_value( $part )
                    || 'auto' eq $part;
        }
        
        if ( $correct && 4 == scalar @values ) {
            $values{'clip-rect-top'}    = shift @values;
            $values{'clip-rect-right'}  = shift @values;
            $values{'clip-rect-bottom'} = shift @values;
            $values{'clip-rect-left'}   = shift @values;
        }
    }
    
    return %values;
}

1;
