package CSS::Prepare::Property::Values;

use Modern::Perl;
use Exporter;

our @ISA    = qw( Exporter );
our @EXPORT = qw(
        get_value_type
        is_colour_value
        is_length_value
        is_percentage_value
        is_url_value
        is_string_value
        
        get_property_type
        is_background_attachment_value
        is_background_repeat_value
        is_border_style_value
        is_font_size_value
        is_font_style_value
        is_font_variant_value
        is_font_weight_value
    );



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
sub is_url_value {
    my $value = shift;
    
    return 1
        if $value =~ m{^ url \( [^\)]+ \) $}x;
    
    return 0;
}
sub is_string_value {
    my $value = shift;
    
    return 1
        if $value =~ m{^ (['"]) [^\1]+ \1 $}x;
    
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

1;
