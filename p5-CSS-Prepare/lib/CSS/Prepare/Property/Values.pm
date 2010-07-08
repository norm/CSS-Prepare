package CSS::Prepare::Property::Values;

use Modern::Perl;
use Exporter;

our @ISA    = qw( Exporter );
our @EXPORT = qw(
        is_length_value
        is_percentage_value
        is_string_value
        is_url_value
        
        is_background_attachment_value
        is_background_colour_value
        is_background_image_value
        is_background_position_value
        is_background_repeat_value
        is_border_collapse_value
        is_border_colour_value
        is_border_radius_corner_value
        is_border_radius_value
        is_border_spacing_value
        is_border_style_value
        is_border_width_value
        is_caption_side_value
        is_clear_value
        is_clip_value
        is_colour_value
        is_content_value
        is_counter_increment_value
        is_counter_reset_value
        is_cursor_value
        is_direction_value
        is_display_value
        is_empty_cells_value
        is_float_value
        is_font_family_value
        is_font_size_line_height_value
        is_font_size_value
        is_font_style_value
        is_font_variant_value
        is_font_weight_value
        is_height_value
        is_letter_spacing_value
        is_line_height_value
        is_list_style_image_value
        is_list_style_position_value
        is_list_style_type_value
        is_margin_width_value
        is_max_height_value
        is_max_width_value
        is_min_height_value
        is_min_width_value
        is_offset_value
        is_opacity_value
        is_outline_colour_value
        is_outline_style_value
        is_outline_width_value
        is_overflow_value
        is_padding_width_value
        is_position_value
        is_quotes_value
        is_table_layout_value
        is_text_align_value
        is_text_decoration_value
        is_text_indent_value
        is_text_transform_value
        is_unicode_bidi_value
        is_vertical_align_value
        is_visibility_value
        is_white_space_value
        is_width_value
        is_word_spacing_value
        is_z_index_value
        
        @standard_directions
        @standard_corners
        
        $background_attachment_value
        $background_colour_value
        $background_image_value
        $background_repeat_value
        $background_position_value
        $border_colour_value
        $individual_border_radius_value
        $border_radius_corner_value
        $border_radius_value
        $border_style_value
        $border_width_value
        $font_family
        $font_family_value
        $font_style_value
        $font_size_value
        $font_style_value
        $font_variant_value
        $font_weight_value
        $length_value
        $line_height_value
        $list_style_type_value
        $list_style_image_value
        $list_style_position_value
        $margin_width_value
        $media_types_value
        $outline_colour_value
        $outline_style_value
        $outline_width_value
        $padding_width_value
        $positive_length_value
        $positive_percentage_value
        $string_value
        $url_value
        
        $concise_format
        $pretty_format
        $concise_separator
        $pretty_separator
    );


# shorthands
our @standard_directions = qw( top right bottom left );
our @standard_corners    = qw( top-left top-right bottom-right bottom-left );

# primitive types
my $integer_value = qr{ [+-]? [0-9]+ }x;
my $positive_integer_value = qr{ [+]? [0-9]+ }x;
my $identifier_value = qr{ [a-z][a-zA-z0-9_-]* }ix;
my $number_value = qr{
        (?:
            (?: $integer_value )
            |
            (?: $integer_value )?
            \. [0-9]+
        )
    }x;
my $positive_number_value = qr{
        (?:
            (?: $positive_integer_value )
            |
            (?: $positive_integer_value )?
            \. [0-9]+
        )
    }x;
our $length_value = qr{
        (?:
            $number_value
            (?: px | em | ex | in | cm | mm | pt | pc )
            |
            0
        )
    }x;
our $positive_length_value = qr{
        (?:
            $positive_number_value
            (?: px | em | ex | in | cm | mm | pt | pc )
            |
            0
        )
    }x;
my $percentage_value = qr{ $number_value % }x;
our $positive_percentage_value = qr{ $positive_number_value % }x;
my $colour_value = qr{
        (?:
              aqua | black  | blue | fuchsia | gray   | green
            | lime | maroon | navy | olive   | orange | purple
            | red  | silver | teal | white   | yellow
            |
            \# [0-9a-fA-F]{6}
            |
            \# [0-9a-fA-F]{3}
            |
            rgb\(
                (?:
                    (?: (?: $number_value | $percentage_value ) , \s* ){2}
                    (?: $number_value | $percentage_value )
                )
            \)
        )
    }x;
our $string_value = qr{
        (?:
            \' (?: \\ \' | [^'] )* \'   # single-quoted
            |                           # or
            \" (?: \\ \" | [^"] )* \"   # double-quoted
        )
    }x;
our $url_value = qr{
        url \( \s*
        (?:
            $string_value \s* \)    # either a string
            |
            [^'"\)] .*?             # or text not including a right paren
            (?<! \\ ) \)            # (unless it is escaped)
        )
    }x;
my $media_types = qr{
        (?:
              all        | braille | embossed | handheld | print
            | projection | screen  | speech   | tty      | tv
        )
    }x;
our $media_types_value = qr{
        $media_types
        (?: \, \s* $media_types )*
    }x;

# descriptive value types
our $background_attachment_value = qr{ (?: scroll | fixed | inherit ) }x;
our $background_colour_value
    = qr{ (?: transparent | inherit | $colour_value ) }x;
our $background_image_value = qr{ (?: none | inherit | $url_value ) }x;
our $background_repeat_value
    = qr{ (?: repeat | repeat-x | repeat-y | no-repeat | inherit ) }x;
my $background_positions_horizontal
    = qr{ (?: left | center | centre | right ) }x;
my $background_positions_vertical
    = qr{ (?: top | center | centre | bottom ) }x;
our $background_position_value = qr{
        (?:
                (?:
                    (?:
                        $percentage_value
                        | $length_value
                        | $background_positions_horizontal
                    )
                    (?:
                        \s+
                        (?:
                              $percentage_value
                            | $length_value
                            | $background_positions_vertical
                        )
                    )?
                )
            |
                (?:
                    $background_positions_horizontal \s+
                    $background_positions_vertical
                )
            |
                (?:
                    $background_positions_vertical \s+
                    $background_positions_horizontal
                )
            |
                (?: $background_positions_vertical )
            |
                inherit
        )
    }x;

my $border_collapse_value = qr{ (?: collapse | separate | inherit ) }x;
our $border_colour_value = qr{ (?: transparent | inherit | $colour_value ) }x;
our $individual_border_radius_value
    = qr{ (?: $positive_length_value | $positive_percentage_value ) }x;
our $border_radius_corner_value = qr{
        $individual_border_radius_value
        (?: \s+ $individual_border_radius_value )?
    }x;
our $border_radius_value = qr{
        $individual_border_radius_value
        (?: \s+ $individual_border_radius_value ){0,3}
        (?:
            \s* / \s*
            $individual_border_radius_value
            (?: \s+ $individual_border_radius_value ){0,3}
        )?
    }x;
my $border_spacing_value = qr{
        (?:
              $length_value
            | $length_value \s+ $length_value
            | inherit
        )
    }x;
our $border_style_value = qr{
        (?:
              dashed | dotted | double | groove | hidden
            | inset  | outset | ridge  | solid

            | none | inherit
        )
    }x;
our $border_width_value
    = qr{ (?: thin | medium | thick | $positive_length_value | inherit ) }x;

my $caption_side_value = qr{ (?: top | bottom | inherit ) }x;
my $clear_value = qr{ (?: left | right | both | none | inherit ) }x;
my $shape_value = qr{
        (?:
            rect \( \s*
                (?: $length_value | auto )
                (?: \s* \, \s* (?: $length_value | auto ) ){3}
            \s* \)
        )
    }x;
my $clip_value = qr{ (?: $shape_value | auto | inherit ) }x;
my $content_repeatable = qr{
        (?:
              open-quote | close-quote | no-open-quote | no-close-quote
            | attr \( $identifier_value \)
            | $string_value | $url_value | $identifier_value
        )
    }x;
my $content_value = qr{
        (?:
              normal | none | inherit
            | $content_repeatable
            | (?:
                  $content_repeatable
                  (?: \s+ $content_repeatable )+
              )
        )
    }x;
my $counter_value = qr{
        (?:
              $identifier_value
            | $identifier_value \s+ $integer_value
        )
    }x;
my $counter_value_content = qr{
        (?:
              $counter_value
            | $counter_value
              (?: \s+ $counter_value )+
            | none
            | inherit
        )
    }x;
my $counter_reset_value = qr{ $counter_value_content }x;
my $counter_increment_value = qr{ $counter_value_content }x;
my $cursor_value = qr{
        (?:
              (?: $url_value \s+ )*
              (?:
                    auto     | crosshair | default   | e-resize  | help
                  | move     | n-resize  | ne-resize | nw-resize | pointer
                  | progress | s-resize  | se-resize | sw-resize | text
                  | w-resize | wait
              )
            | inherit
        )
    }x;

my $direction_value = qr{ (?: ltr | rtl | inherit ) }x;
my $display_value = qr{
        (?:
              block              | inline             | inline-block
            | inline-table       | list-item          | none
            | run-in             | table              | table-caption
            | table-cell         | table-column       | table-column-group
            | table-footer-group | table-header-group | table-row
            | table-row-group
            
            | none | inherit
        )
    }x;
my $empty_cells_value = qr{ (?: show | hide | inherit ) }x;

my $float_value = qr{ (?: left | right | none | inherit ) }x;
our $font_family = qr{
        (?:
              serif | sans-serif | cursive | fantasy | monospace
            | $identifier_value
            | $string_value
            | inherit
        )
    }x;
our $font_family_value = qr{
        (?:
            $font_family
            |
            (?: $font_family (?: \s* \, \s* $font_family )+ )
        )
    }x;
our $line_height_value = qr{
        (?:   normal
            | $number_value | $length_value | $percentage_value
            | inherit
        )
    }x;
our $font_size_value = qr{
        (?:
              xx-small | x-small | small  | medium | large | x-large
            | xx-large | smaller | larger | inherit
            | $length_value | $percentage_value
        )
    }x;
my $font_size_line_height_value
    = qr{ $font_size_value / $line_height_value }x;
our $font_style_value = qr{ (?: italic | oblique | normal | inherit ) }x;
our $font_variant_value = qr{ (?: normal | small-caps | inherit ) }x;
our $font_weight_value = qr{
        (?:
              normal | bold | bolder | lighter
            | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900
            | inherit
        )
    }x;

my $height_value
    = qr{ (?: $length_value | $percentage_value | auto | inherit ) }x;
my $letter_spacing_value = qr{ (?: normal | $length_value | inherit ) }x;
our $list_style_image_value = qr{ (?: $url_value | none | inherit ) }x;
our $list_style_position_value = qr{ (?: inside | outside | inherit ) }x;
our $list_style_type_value = qr{
        (?:
              armenian    | circle      | decimal     | decimal-leading-zero
            | disc        | georgian    | lower-alpha | lower-greek
            | lower-latin | lower-roman | upper-alpha | upper-latin
            | upper-roman
            
            | none | inherit
        )
    }x;

our $margin_width_value
    = qr{ (?: $length_value | $percentage_value | auto | inherit ) }x;
my $max_height_value
    = qr{ (?: $length_value | $percentage_value | none | inherit ) }x;
my $max_width_value
    = qr{ (?: $length_value | $percentage_value | none | inherit ) }x;
my $min_height_value
    = qr{ (?: $length_value | $percentage_value | inherit ) }x;
my $min_width_value
    = qr{ (?: $length_value | $percentage_value | inherit ) }x;

my $offset_value
    = qr{ (?: $length_value | $percentage_value | auto | inherit ) }x;
my $opacity_value = qr{ (?: $number_value | inherit ) }x;
our $outline_colour_value = qr{ (?: invert | inherit | $colour_value ) }x;
our $outline_style_value = qr{ (?: $border_style_value ) }x;
our $outline_width_value = qr{ (?: $border_width_value ) }x;
my $overflow_value = qr{ (?: visible | hidden | scroll | auto | inherit ) }x;
our $padding_width_value = qr{
        (?: $positive_length_value | $positive_percentage_value | inherit )
    }x;
my $position_value
    = qr{ (?: absolute | fixed | relative | static | inherit ) }x;
my $quotes_value = qr{
        (?:
              (?:
                  (?: $string_value \s+ $string_value )
                  (?: \s+ $string_value \s+ $string_value )*
              )
            | none | inherit
        )
    }x;

my $table_layout_value = qr{ (?: auto | fixed | inherit ) }x;
my $text_align_value
    = qr{ (?: left | right | center | justify | inherit ) }x;
my $text_decoration_value = qr{
       (?: none | underline | overline | line-through | blink | inherit )
   }x;
my $text_indent_value
    = qr{ (?: $length_value | $percentage_value | inherit ) }x;
my $text_transform_value
    = qr{ (?: capitalize | uppercase | lowercase | none | inherit ) }x;

my $unicode_bidi_value
    = qr{ (?: normal | embed | bidi-override | inherit ) }x;
my $vertical_align_value = qr{
        (?:
              baseline | sub    | super  | top
            | text-top | middle | bottom | text-bottom
            | $length_value | $percentage_value
            | inherit
        )
    }x;
my $visibility_value = qr{ (?: visible | hidden | collapse | inherit ) }x;
my $white_space_value
    = qr{ (?: normal | pre | nowrap | pre-wrap | pre-line | inherit ) }x;
my $width_value
    = qr{ (?: $length_value | $percentage_value | auto | inherit ) }x;
my $word_spacing_value = qr{ (?: normal | $length_value | inherit ) }x;
my $z_index_value = qr{ (?: $integer_value | auto | inherit ) }x;



our $concise_format    = "%s%s;";
our $pretty_format     = "    %-23s %s;\n";
our $concise_separator = ' ';
our $pretty_separator  = "\n" . ( ' ' x 28 );


sub is_length_value {
    my $value = shift;
    return $value =~ m{^ $length_value $}x;
}
sub is_percentage_value {
    my $value = shift;
    return $value =~ m{^ $percentage_value $}x;
}
sub is_string_value {
    my $value = shift;
    return $value =~ m{^ $string_value $}x;
}
sub is_url_value {
    my $value = shift;
    return $value =~ m{^ $url_value $}x;
}

sub is_background_attachment_value {
    my $value = shift;
    return $value =~ m{^ $background_attachment_value $}x;
}
sub is_background_colour_value {
    my $value = shift;
    return $value =~ m{^ $background_colour_value $}x;
}
sub is_background_image_value {
    my $value = shift;
    return $value =~ m{^ $background_image_value $}x;
}
sub is_background_position_value {
    my $value = shift;
    return $value =~ m{^ $background_position_value $}x;
}
sub is_background_repeat_value {
    my $value = shift;
    return $value =~ m{^ $background_repeat_value $}x;
}
sub is_border_collapse_value {
    my $value = shift;
    return $value =~ m{^ $border_collapse_value $}x;
}
sub is_border_colour_value {
    my $value = shift;
    return $value =~ m{^ $border_colour_value $}x;
}
sub is_border_radius_corner_value {
    my $value = shift;
    return $value =~ m{^ $border_radius_corner_value $}x;
}
sub is_border_radius_value {
    my $value = shift;
    return $value =~ m{^ $border_radius_value $}x;
}
sub is_border_spacing_value {
    my $value = shift;
    return $value =~ m{^ $border_spacing_value $}x;
}
sub is_border_style_value {
    my $value  = shift;
    return $value =~ m{^ $border_style_value $}x;
}
sub is_border_width_value {
    my $value = shift;
    return $value =~ m{^ $border_width_value $}x;
}
sub is_caption_side_value {
    my $value = shift;
    return $value =~ m{^ $caption_side_value $}x;
}
sub is_clear_value {
    my $value = shift;
    return $value =~ m{^ $clear_value $}x;
}
sub is_clip_value {
    my $value = shift;
    return $value =~ m{^ $clip_value $}x;
}
sub is_colour_value {
    my $value = shift;
    return $value =~ m{^ $colour_value $}x;
}
sub is_content_value {
    my $value = shift;
    return $value =~ m{^ $content_value $}x;
}
sub is_counter_increment_value {
    my $value = shift;
    return $value =~ m{^ $counter_increment_value $}x;
}
sub is_counter_reset_value {
    my $value = shift;
    return $value =~ m{^ $counter_reset_value $}x;
}
sub is_cursor_value {
    my $value = shift;
    return $value =~ m{^ $cursor_value $}x;
}
sub is_direction_value {
    my $value = shift;
    return $value =~ m{^ $direction_value $}x;
}
sub is_display_value {
    my $value = shift;
    return $value =~ m{^ $display_value $}x;
}
sub is_empty_cells_value {
    my $value = shift;
    return $value =~ m{^ $empty_cells_value $}x;
}
sub is_float_value {
    my $value = shift;
    return $value =~ m{^ $float_value $}x;
}
sub is_font_family_value {
    my $value = shift;
    return $value =~ m{^ $font_family_value $}x;
}
sub is_font_size_line_height_value {
    my $value = shift;
    return $value =~ m{^ $font_size_line_height_value $}x;
}
sub is_font_size_value {
    my $value = shift;
    return $value =~ m{^ $font_size_value $}x;
}
sub is_font_style_value {
    my $value = shift;
    return $value =~ m{^ $font_style_value $}x;
}
sub is_font_variant_value {
    my $value = shift;
    return $value =~ m{^ $font_variant_value $}x;
}
sub is_font_weight_value {
    my $value = shift;
    return $value =~ m{^ $font_weight_value $}x;
}
sub is_height_value {
    my $value = shift;
    return $value =~ m{^ $height_value $}x;
}
sub is_letter_spacing_value {
    my $value = shift;
    return $value =~ m{^ $letter_spacing_value $}x;
}
sub is_line_height_value {
    my $value = shift;
    return $value =~ m{^ $line_height_value $}x;
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
sub is_margin_width_value {
    my $value = shift;
    return $value =~ m{^ $margin_width_value $}x;
}
sub is_max_height_value {
    my $value = shift;
    return $value =~ m{^ $max_height_value $}x;
}
sub is_max_width_value {
    my $value = shift;
    return $value =~ m{^ $max_width_value $}x;
}
sub is_min_height_value {
    my $value = shift;
    return $value =~ m{^ $min_height_value $}x;
}
sub is_min_width_value {
    my $value = shift;
    return $value =~ m{^ $min_width_value $}x;
}
sub is_offset_value {
    my $value = shift;
    return $value =~ m{^ $offset_value $}x;
}
sub is_opacity_value {
    my $value = shift;
    
    if ( $value =~ m{^ $opacity_value $}x ) {
        return 1
            if ( 0 <= $value && 1 >= $value );
    }
    
    return 0;
}
sub is_outline_colour_value {
    my $value = shift;
    return $value =~ m{^ $outline_colour_value $}x;
}
sub is_outline_style_value {
    my $value  = shift;
    return $value =~ m{^ $outline_style_value $}x;
}
sub is_outline_width_value {
    my $value = shift;
    return $value =~ m{^ $outline_width_value $}x;
}
sub is_overflow_value {
    my $value = shift;
    return $value =~ m{^ $overflow_value $}x;
}
sub is_padding_width_value {
    my $value = shift;
    return $value =~ m{^ $padding_width_value $}x;
}
sub is_position_value {
    my $value = shift;
    return $value =~ m{^ $position_value $}x;
}
sub is_quotes_value {
    my $value = shift;
    return $value =~ m{^ $quotes_value $}x;
}
sub is_table_layout_value {
    my $value = shift;
    return $value =~ m{^ $table_layout_value $}x;
}
sub is_text_align_value {
    my $value = shift;
    return $value =~ m{^ $text_align_value $}x;
}
sub is_text_decoration_value {
    my $value = shift;
    return $value =~ m{^ $text_decoration_value $}x;
}
sub is_text_indent_value {
    my $value = shift;
    return $value =~ m{^ $text_indent_value $}x;
}
sub is_text_transform_value {
    my $value = shift;
    return $value =~ m{^ $text_transform_value $}x;
}
sub is_unicode_bidi_value {
    my $value = shift;
    return $value =~ m{^ $unicode_bidi_value $}x;
}
sub is_vertical_align_value {
    my $value = shift;
    return $value =~ m{^ $vertical_align_value $}x;
}
sub is_visibility_value {
    my $value = shift;
    return $value =~ m{^ $visibility_value $}x;
}
sub is_white_space_value {
    my $value = shift;
    return $value =~ m{^ $white_space_value $}x;
}
sub is_width_value {
    my $value = shift;
    return $value =~ m{^ $width_value $}x;
}
sub is_word_spacing_value {
    my $value = shift;
    return $value =~ m{^ $word_spacing_value $}x;
}
sub is_z_index_value {
    my $value = shift;
    return $value =~ m{^ $z_index_value $}x;
}

1;
