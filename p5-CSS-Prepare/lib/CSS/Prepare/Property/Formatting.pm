package CSS::Prepare::Property::Formatting;

use Modern::Perl;
use CSS::Prepare::Property::Values;



sub parse {
    my $self        = shift;
    my $has_hack    = shift;
    my %declaration = @_;
    
    my $property = $declaration{'property'};
    my $value    = $declaration{'value'};
    my %canonical;
    my @errors;
    
    my $valid_property_or_error = sub {
            my $type  = shift;
            
            my $sub      = "is_${type}_value";
            my $is_valid = 0;
            
            eval {
                no strict 'refs';
                $is_valid = &$sub( $value );
            };
            
            if ( $is_valid ) {
                $canonical{ $property } = $value;
            }
            else {
                $type =~ s{_}{-}g;
                push @errors, {
                        error => "invalid ${type} property: '${value}'"
                    };
            }
        };
    
    foreach my $type qw( clear direction display float position ) {
        &$valid_property_or_error( $type )
            if $type eq $property;
    }
    
    &$valid_property_or_error( 'height' )
        if 'height' eq $property;
    
    &$valid_property_or_error( 'max_height' )
        if 'max-height' eq $property;
    
    &$valid_property_or_error( 'min_height' )
        if 'min-height' eq $property;
    
    &$valid_property_or_error( 'width' )
        if 'width' eq $property;
    
    &$valid_property_or_error( 'max_width' )
        if 'max-width' eq $property;
    
    &$valid_property_or_error( 'min_width' )
        if 'min-width' eq $property;
    
    &$valid_property_or_error( 'vertical_align' )
        if 'vertical-align' eq $property;
    
    &$valid_property_or_error( 'line_height' )
        if 'line-height' eq $property;
    
    &$valid_property_or_error( 'direction' )
        if 'direction' eq $property;
    
    &$valid_property_or_error( 'unicode_bidi' )
        if 'unicode-bidi' eq $property;
    
    &$valid_property_or_error( 'z_index' )
        if 'z-index' eq $property;
    
    foreach my $offset qw( top right bottom left ) {
        &$valid_property_or_error( 'offset' )
            if $offset eq $property;
    }
    
    return \%canonical, \@errors;
}
sub output {
    my $self  = shift;
    my $block = shift;
    my @output;
    
    # line-height is dealt with in Font.pm not here; this so
    # it can be collapsed into font shorthand if possible
    my @properties = qw(
            bottom      clear       direction     display
            float       height      left          max-height
            max-width   min-height  min-width     position
            right       top         unicode-bidi  vertical-align
            width       z-index
        );
    
    foreach my $property ( @properties ) {
        my $value = $block->{ $property };
        
        push @output, sprintf $self->output_format, "${property}:", $value
            if defined $value;
    }
    
    return @output;
}

1;
