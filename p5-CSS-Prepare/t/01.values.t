use Modern::Perl;
use Test::More  tests => 478;

use CSS::Prepare::Property::Values;


# test colours
{
    my @valid_colour_values = ( 'red', '#fff', '#FFF', '#FFFFFF' );
    foreach my $value ( @valid_colour_values ) {
        ok( is_colour_value( $value ),
            "colour: '$value'" );
    }

    my @invalid_colour_values = ( '#c', '#cccc', '#hbhbhb', 'hotpink' );
    foreach my $value ( @invalid_colour_values ) {
        ok( ! is_colour_value( $value ),
            "not colour: '$value'" );
    }
}

# test numerical values
{
    my @invalid_zero_values = qw( -0 +0 );
    foreach my $value ( @invalid_zero_values ) {
        ok( ! is_length_value( $value ),
            "invalid zero: '$value'" );
    }

    my @valid_length_values
        = qw( 0 +0px 5px .5em 10.0001em 15ex 20in 25cm 30mm 35pt 40pc );
    foreach my $value ( @valid_length_values ) {
        ok( is_length_value( $value ),
            "length: '$value'" );
        ok( ! is_percentage_value( $value ),
            "not percentage: '$value'" );
    }

    my @valid_percentage_values = qw( 0.254338% +150% -5% );
    foreach my $value ( @valid_percentage_values ) {
        ok( is_percentage_value( $value ),
            "percentage: '$value'" );
        ok( ! is_length_value( $value ),
            "not length: '$value'" );
    }
}

# test strings
{
    my @strings = ( '"hello"', q('hello'), qq('that\\'s mine'), qq("\\"") );
    foreach my $value ( @strings ) {
        ok( is_string_value( $value ),
            "string: ($value)" );
    }
    ok( ! is_string_value( q('it's here') ),
        "not string: ('it's here')" );
}

# test url values
{
    # co-incidentally also tests string values
    my @valid_url_values = (
            'url(blah.gif)',
            'url( blah\).gif )',
            'url( http://www.example.com/blah.gif )',
            q(url( 'bob.gif' )),
            'url( "https://secure.example.com/blah.gif" )',
        );
    foreach my $value ( @valid_url_values ) {
        ok( is_url_value( $value ),
            "url: '$value'" );
    }

    my @invalid_url_values = (
            'blah.gif',
            'png(something.png)',
        );
    foreach my $value ( @invalid_url_values ) {
        ok( ! is_url_value( $value ),
            "not url: '$value'" );
    }
}

# test background values
{
    foreach my $value qw( scroll fixed inherit ) {
        ok( is_background_attachment_value( $value ),
            "background-attachment: '$value'" );
    }
    ok( ! is_background_attachment_value( 'relative' ),
        "not background-attachment: 'relative'" );
    
    
    # other background-color values are tested by colours above
    my @colours = ( 'inherit', 'transparent', 'red', '#000' );
    foreach my $value ( @colours ) {
        ok( is_background_colour_value( $value ),
            "background-color: '$value'" );
    }
    ok( ! is_background_colour_value( '#cc' ),
        "not background-color: '#cc'" );
    
    
    # other background-image values are tested by urls above
    foreach my $value qw( none  url(blah.gif)  inherit ) {
        ok( is_background_image_value( $value ),
            "background-image: '$value'" );
    }
    ok( ! is_background_image_value( 'blah.gif'),
        "not background-image: 'blah.gif'" );
    
    
    foreach my $value qw( repeat repeat-x repeat-y no-repeat inherit ) {
        ok( is_background_repeat_value( $value ),
            "background-repeat: '$value'" );
    }
    ok( ! is_background_repeat_value( 'repeat-z' ),
        "not background-repeat: 'repeat-z'" );
    
    
    my @positions = (
            'left', 'center', 'centre', 'right', 'top', 'bottom',
            'left center', 'center center', 'centre centre',
            'left top', 'top left', 'top right',
            'bottom left', 'bottom right', 'top left', 'top right',
            '50%', '10px', '50% 50%', '10px top', 'left 50%',
            'inherit',
        );
    foreach my $value ( @positions ) {
        ok( is_background_position_value( $value ),
            "background-position: '$value'" );
    }
    ok( ! is_background_position_value( '50% left' ),
        "not background-position: '50% left'" );
    ok( ! is_background_position_value( 'bottom 50%' ),
        "not background-position: 'bottom 50%'" );
}

# test border values
{
    my @border_style_values = qw(
            none     hidden  dotted  dashed  solid
            double   groove  ridge   inset   outset
            inherit
        );
    foreach my $value ( @border_style_values ) {
        ok( is_border_style_value( $value ),
            "border-style: '$value'" );
    }
    ok( ! is_border_style_value( 'groovy' ),
        "not border-style: 'groovy'" );
    
    # other border-width values are tested by numerical values above
    foreach my $value qw( thin  medium  thick  inherit  2px ) {
        ok( is_border_width_value( $value ),
            "border-width: '$value'" );
    }
    ok( ! is_border_width_value( 'stroke' ),
        "not border-width: 'stroke'" );
    ok( ! is_border_width_value( '-2px' ),
        "not border-width: '-2px'" );
    
    # other border-color values are tested by colours above
    my @colours = ( 'inherit', 'transparent', 'red', '#000' );
    foreach my $value ( @colours ) {
        ok( is_border_colour_value( $value ),
            "border-color: '$value'" );
    }
    ok( ! is_border_colour_value( '#cc' ),
        "not border-color: '#cc'" );
    
    my @corner_radii = (
            '5px', '5px 2px', '.5em 1px',
        );
    foreach my $value ( @corner_radii ) {
        ok( is_border_radius_corner_value( $value ),
            "border-radius corner: '$value'" );
    }
    
    my @radii = ( '5em 2em 1em', '5em / 1px 2px 3px 4px' );
    foreach my $value ( @corner_radii, @radii ) {
        ok( is_border_radius_value( $value ),
            "border-radius: '$value'" );
    }
    
    foreach my $value ( @radii ) {
        ok( ! is_border_radius_corner_value( $value ),
            "not border-radius corner: '$value'" );
    }
}

# test margins and padding
{
    # other lengths and percentages are tested above
    ok( is_margin_width_value( '5px' ),
        "margin-width: '5px'" );
    ok( is_margin_width_value( '-2em' ),
        "margin-width: '-2em'" );
    ok( is_margin_width_value( '10%' ),
        "margin-width: '10%'" );
    ok( is_margin_width_value( 'auto' ),
        "margin-width: 'auto'" );
    ok( is_margin_width_value( 'inherit' ),
        "margin-width: 'inherit'" );
    ok( ! is_margin_width_value( '20' ),
        "not margin-width: '20'" );
    
    
    ok( is_padding_width_value( '5px' ),
        "padding-width: '5px'" );
    ok( ! is_padding_width_value( '-2em' ),
        "not padding-width: '-2em'" );
    ok( is_padding_width_value( '10%' ),
        "padding-width: '10%'" );
    ok( is_padding_width_value( 'inherit' ),
        "padding-width: 'inherit'" );
    ok( ! is_padding_width_value( '20' ),
        "not padding-width: '20'" );
}

# test visual formatting
{
    my @valid_display_values = qw(
            block               inline              inline-block
            inline-table        list-item           run-in
            table               table-caption       table-cell
            table-column        table-column-group  table-footer-group
            table-header-group  table-row           table-row-group
            inherit             none
        );
    foreach my $value ( @valid_display_values ) {
        ok( is_display_value( $value ),
            "display: '$value'" );
    }
    ok( ! is_display_value( 'run-on' ),
        "not display: 'run-on'" );
    
    
    foreach my $value qw( static  relative  absolute  fixed  inherit ) {
        ok( is_position_value( $value ),
            "position: '$value'" );
    }
    ok( ! is_position_value( 'float' ),
        "not position: 'float'" );
    
    
    # top, right, bottom, left properties
    # other lengths and percentages are tested above
    foreach my $value qw( 5px  20%  auto  inherit ) {
        ok( is_offset_value( $value ),
            "offset: '$value'" );
    }
    ok( ! is_offset_value( 'bottom' ),
        "not offset: 'bottom'" );
    
    
    foreach my $value qw( left  right  none  inherit ) {
        ok( is_float_value( $value ),
            "float: '$value'" );
    }
    ok( ! is_float_value( 'side' ),
        "not float: 'side'" );
    
    
    foreach my $value qw( left  right  both  none  inherit ) {
        ok( is_clear_value( $value ),
            "clear: '$value'" );
    }
    ok( ! is_clear_value( 'all' ),
        "not clear: 'all'" );
    
    
    foreach my $value qw( auto  5  inherit ) {
        ok( is_z_index_value( $value ),
            "z-index: '$value'" );
    }
    ok( ! is_z_index_value( '10px' ),
        "not z-index: '10px'" );
    
    
    foreach my $value qw( ltr  rtl  inherit ) {
        ok( is_direction_value( $value ),
            "direction: '$value'" );
    }
    ok( ! is_direction_value( 'backwards' ),
        "not direction: 'backwards'" );
    
    
    foreach my $value qw( embed  bidi-override  inherit  normal ) {
        ok( is_unicode_bidi_value( $value ),
            "unicode-bidi: '$value'" );
    }
    ok( ! is_unicode_bidi_value( 'bidi-curious' ),
        "not unicode-bidi: 'bidi-curious'" );
    
    
    # other lengths and percentages are tested above
    my @vertical_align_values = qw(
          baseline  sub     super   top
          text-top  middle  bottom  text-bottom
          5px       20%     inherit
        );
    foreach my $value ( @vertical_align_values ) {
        ok( is_vertical_align_value( $value ),
            "vertical-align: '$value'" );
    }
    ok( ! is_vertical_align_value( 'up' ),
        "not vertical-align: 'up'" );
    ok( ! is_vertical_align_value( '5' ),
        "not vertical-align: '5'" );
    
    
    # other lengths and percentages are tested above
    foreach my $value qw( 5px 20% inherit ) {
        ok( is_height_value( $value ),
            "height: '$value'" );
        ok( is_max_height_value( $value ),
            "max-height: '$value'" );
        ok( is_min_height_value( $value ),
            "min-height: '$value'" );
        ok( is_width_value( $value ),
            "width: '$value'" );
        ok( is_max_width_value( $value ),
            "max-width: '$value'" );
        ok( is_min_width_value( $value ),
            "min-width: '$value'" );
    }
    ok( is_height_value( 'auto' ),
        "height: 'auto'" );
    ok( ! is_max_height_value( 'auto' ),
        "not max-height: 'auto'" );
    ok( ! is_min_height_value( 'auto' ),
        "not min-height: 'auto'" );
    ok( is_width_value( 'auto' ),
        "width: 'auto'" );
    ok( ! is_max_width_value( 'auto' ),
        "not max-width: 'auto'" );
    ok( ! is_min_width_value( 'auto' ),
        "not min-width: 'auto'" );
    ok( ! is_height_value( 'none' ),
        "height: 'none'" );
    ok( is_max_height_value( 'none' ),
        "max-height: 'none'" );
    ok( ! is_min_height_value( 'none' ),
        "not min-height: 'none'" );
    ok( ! is_width_value( 'none' ),
        "not width: 'none'" );
    ok( is_max_width_value( 'none' ),
        "max-width: 'none'" );
    ok( ! is_min_width_value( 'none' ),
        "not min-width: 'none'" );
    
    
    # other lengths and percentages are tested above
    ok( is_line_height_value( 'normal' ),
        "line-height: 'normal'" );
    ok( is_line_height_value( '1.2' ),
        "line-height: '1.2'" );
    ok( is_line_height_value( '5px' ),
        "line-height: '5px'" );
    ok( is_line_height_value( '20%' ),
        "line-height: '20%'" );
    ok( is_line_height_value( 'inherit' ),
        "line-height: 'inherit'" );
    ok( ! is_line_height_value( 'tall' ),
        "not line-height: 'tall'" );
}

# test generated content
{
    my @contents = (
            'normal', 'none', '"hello world"', 'url(blah.gif)', 'attr(href)',
            'open-quote', 'close-quote', 'no-open-quote', 'no-close-quote',
            'inherit',
            # counter is just an ID
            'counter', 'blah',
            # can have multiples of everything but normal, none and inherit
            'open-quote close-quote', 'open-quote attr(href)',
            '"hello" "world"'
        );
    foreach my $value ( @contents ) {
        ok( is_content_value( $value ),
            "content: '$value'" );
    }
    ok( ! is_content_value( '5px' ),
        "not content: '5px'" );
    
    
    my @quotes = (
            q('"' '"'), q('"' "'"), q("'" "'"), q("“" "”" '"' '"'),
            'inherit', 'none'
        );
    foreach my $value ( @quotes ) {
        ok( is_quotes_value( $value ),
            "quotes: ($value)" );
    }
    ok( ! is_quotes_value( q("'" "'" '"') ),
        q(not quotes: "'" "'" '"') );
    ok( ! is_quotes_value( 'curly' ),
        q(not quotes: 'curly') );
    
    
    my @counter_values = (
            'blah', 'blah 2', 'blah blurgh 2', 'blah 1 blurgh 2',
            'none', 'inherit'
        );
    foreach my $value ( @counter_values ) {
        ok( is_counter_reset_value( $value ),
            "counter-reset: '$value'" );
        ok( is_counter_increment_value( $value ),
            "counter-increment: '$value'" );
    }
    ok( ! is_counter_reset_value( "blah 5px" ),
        "counter-reset: 'blah 5px'" );
    ok( ! is_counter_increment_value( "blah 5px" ),
        "counter-increment: 'blah 5px'" );
    
    
    my @list_style_type_values = qw(
            armenian     circle       decimal      decimal-leading-zero
            disc         georgian     lower-alpha  lower-greek
            lower-latin  lower-roman  upper-alpha  upper-latin
            upper-roman  none         inherit
        );
    foreach my $value ( @list_style_type_values ) {
        ok( is_list_style_type_value( $value ),
            "list-style-type: '$value'" );
    }
    ok( ! is_list_style_type_value( 'upper-greek' ),
        "not list-style-type: 'upper-greek'" );
    
    
    foreach my $value qw( url(blah.gif)  none  inherit ) {
        ok( is_list_style_image_value( $value ),
            "list-style-image: '$value'" );
    }
    ok( ! is_list_style_image_value( 'disc' ),
        "list-style-image: 'disc'" );
    
    
    foreach my $value qw( inside  outside  inherit ) {
        ok( is_list_style_position_value( $value ),
            "list-style-position: '$value'" );
    }
    ok( ! is_list_style_position_value( 'all-about' ),
        "not list-style-position: 'all-about'" );
}

# test fonts
{
    my @font_families = (
            'Arial', 'Helvetica', q('Monaco'), q("Courier"),
            '"Gill Sans"', '"Times New Roman"',
            'serif', 'sans-serif', 'cursive', 'fantasy', 'monospace',
            q("Arial", "Helvetica", sans-serif),
            q(Arial, Helvetica, sans-serif),
            q(Arial,Helvetica,sans-serif),
            'inherit',
        );
    foreach my $value ( @font_families ) {
        ok( is_font_family_value( $value ),
            "font-family: '$value'" );
    }
    ok( ! is_font_family_value( 'Gill Sans' ),
        "font-family: 'Gill Sans'" );
    ok( ! is_font_family_value( '"Arial" sans-serif' ),
        q(font-family: '"Arial" sans-serif') );
    
    
    foreach my $value qw( normal  italic  oblique  inherit ) {
        ok( is_font_style_value( $value ),
            "font-style: '$value'" );
    }
    ok( ! is_font_style_value( 'slanted' ),
        "not font-style: 'slanted'" );
    
    
    foreach my $value qw( normal  small-caps  inherit ) {
        ok( is_font_variant_value( $value ),
            "font-variant: '$value'" );
    }
    ok( ! is_font_variant_value( 'drop-cap' ),
        "not font-variant: 'drop-cap'" );
    
    
    my @font_weight_values = qw(
            normal  bold  bolder  lighter  inherit
            100     200   300     400      500
            600     700   800     900
        );
    foreach my $value ( @font_weight_values ) {
        ok( is_font_weight_value( $value ),
            "font-weight: '$value'" );
    }
    ok( ! is_font_weight_value( 'light' ),
        "not font-weight: 'light'" );
    
    
    my @font_sizes = qw(
            xx-small  x-small  small  medium  large  x-large  xx-large 
            larger    smaller  inherit
        );
    foreach my $value ( @font_sizes, '5px', '123.8%' ) {
        ok( is_font_size_value( $value ),
            "font-size: '$value'" );
    }
    ok( ! is_font_size_value( '23' ),
        "not font-size: '23'" );
    
    
    foreach my $value ( '12px/20px', '1em/1.2' ) {
        ok( is_font_size_line_height_value( $value ),
            "font-size/line-height: '$value'" );
    }
    ok( ! is_font_size_line_height_value( '5px' ),
        "not font-size/line-height: '5px'" );
}

# test text
{
    foreach my $value qw( 20px  80%  inherit ) {
        ok( is_text_indent_value( $value ),
            "text-indent: '$value'" );
    }
    ok( ! is_text_indent_value( '8' ),
        "not text-indent: '8'" );
    
    
    foreach my $value qw( left  right  center  justify  inherit ) {
        ok( is_text_align_value( $value ),
            "text-align: '$value'" );
    }
    ok( ! is_text_align_value( 'full' ),
        "not text-align: 'full'" );
    
    
    my @text_decorations
        = qw( none  underline  overline  line-through  blink  inherit );
    foreach my $value ( @text_decorations ) {
        ok( is_text_decoration_value( $value ),
            "text-decoration: '$value'" );
    }
    ok( ! is_text_decoration_value( 'strike' ),
        "not text-decoration: 'strike'" );
    
    
    foreach my $value qw( normal  5px  inherit ) {
        ok( is_letter_spacing_value( $value ),
            "letter-spacing: '$value'" );
        ok( is_word_spacing_value( $value ),
            "word-spacing: '$value'" );
    }
    ok( ! is_letter_spacing_value( '8' ),
        "not letter-spacing: '8'" );
    ok( ! is_word_spacing_value( '8' ),
        "not word-spacing: '8'" );
    
    
    foreach my $value qw( capitalize  uppercase  lowercase  none  inherit ) {
        ok( is_text_transform_value( $value ),
            "text-transform: '$value'" );
    }
    ok( ! is_text_transform_value( 'camel-case' ),
        "not text-transform: 'camel-case'" );
    
    
    foreach my $value qw( normal  pre  nowrap  pre-wrap  pre-line  inherit ) {
        ok( is_white_space_value( $value ),
            "white-space: '$value'" );
    }
    ok( ! is_white_space_value( 'newline' ),
        "not white-space: 'newline'" );
}

# test tables
{
    foreach my $value qw( top  bottom  inherit ) {
        ok( is_caption_side_value( $value ),
            "caption-side: '$value'" );
    }
    ok( ! is_caption_side_value( 'left' ),
        "not caption-side: 'left'" );
    
    
    foreach my $value qw( auto  fixed  inherit ) {
        ok( is_table_layout_value( $value ),
            "table-layout: '$value'" );
    }
    ok( ! is_table_layout_value( 'broken' ),
        "not table-layout: 'broken'" );
    
    
    foreach my $value qw( collapse  separate  inherit ) {
        ok( is_border_collapse_value( $value ),
            "border-collapse: '$value'" );
    }
    ok( ! is_border_collapse_value( 'join' ),
        "not border-collapse: 'join'" );
    
    
    my @spacings = ( '5px', '5px 2px', 'inherit' );
    foreach my $value ( @spacings ) {
        ok( is_border_spacing_value( $value ),
            "border-spacing: '$value'" );
    }
    ok( ! is_border_spacing_value( '8px 5px 2px' ),
        "not border-spacing: '8px 5px 2px'" );
    
    
    foreach my $value qw( show  hide  inherit ) {
        ok( is_empty_cells_value( $value ),
            "empty-cells: '$value'" );
    }
    ok( ! is_empty_cells_value( 'drain' ),
        "not empty-cells: 'drain'" );
}

# test visual effects
{
    foreach my $value qw( visible  hidden  scroll  auto  inherit ) {
        ok( is_overflow_value( $value ),
            "overflow: '$value'" );
    }
    ok( ! is_overflow_value( '8' ),
        "not overflow: '8'" );
    
    
    my @clips = (
            'rect(25px,20px,0,50px)', 'rect( 5px, 10px, 20px, auto )',
            'auto', 'inherit'
        );
    foreach my $value ( @clips ) {
        ok( is_clip_value( $value ),
            "clip: '$value'" );
    }
    ok( ! is_clip_value( 'square' ),
        "not clip: 'square'" );
    
    
    foreach my $value qw( visible  hidden  collapse  inherit ) {
        ok( is_visibility_value( $value ),
            "visibility: '$value'" );
    }
    ok( ! is_visibility_value( 'invisible' ),
        "not visibility: 'invisible'" );
}

# test user interface
{
    my @cursors = qw(
            auto       crosshair  default    pointer    move       e-resize
            ne-resize  nw-resize  n-resize   se-resize  sw-resize  s-resize
            w-resize   text       wait       help       progress
            inherit
        );
    foreach my $value ( @cursors ) {
        ok( is_cursor_value( $value ),
            "cursor: '$value'" );
    }
    ok( is_cursor_value( 'url(blah.gif) crosshair' ),
        "cursor: 'url(blah.gif) crosshair'" );
    ok( ! is_cursor_value( 'url(blah.gif)' ),
        "not cursor: 'url(blah.gif)'" );
    ok( ! is_cursor_value( 'crosshair sw-resize' ),
        "not cursor: 'crosshair sw-resize'" );
    
    
    my @outline_style_values = qw(
            none     hidden  dotted  dashed  solid
            double   groove  ridge   inset   outset
            inherit
        );
    foreach my $value ( @outline_style_values ) {
        ok( is_outline_style_value( $value ),
            "outline-style: '$value'" );
    }
    ok( ! is_outline_style_value( 'groovy' ),
        "not outline-style: 'groovy'" );
    
    # other outline-width values are tested by numerical values above
    foreach my $value qw( thin  medium  thick  inherit  2px ) {
        ok( is_outline_width_value( $value ),
            "outline-width: '$value'" );
    }
    ok( ! is_outline_width_value( 'stroke' ),
        "not outline-width: 'stroke'" );
    
    # other outline-color values are tested by colours above
    my @colours = ( 'inherit', 'invert', 'red', '#000' );
    foreach my $value ( @colours ) {
        ok( is_outline_colour_value( $value ),
            "outline-color: '$value'" );
    }
    ok( ! is_outline_colour_value( 'transparent' ),
        "not outline-color: 'transparent'" );
    ok( ! is_outline_colour_value( '#cc' ),
        "not outline-color: '#cc'" );
}
