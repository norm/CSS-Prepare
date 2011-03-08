package CSS::Prepare::Property::Tables;

use Modern::Perl;
use CSS::Prepare::Property::Values;



sub parse {
    my $self        = shift;
    my $has_hack    = shift;
    my $location    = shift;
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
    
    &$valid_property_or_error( 'caption_side' )
        if 'caption-side' eq $property;
    
    &$valid_property_or_error( 'table_layout' )
        if 'table-layout' eq $property;
    
    &$valid_property_or_error( 'border_collapse' )
        if 'border-collapse' eq $property;
    
    &$valid_property_or_error( 'border_spacing' )
        if 'border-spacing' eq $property;
    
    &$valid_property_or_error( 'empty_cells' )
        if 'empty-cells' eq $property;
    
    return \%canonical, \@errors;
}
sub output {
    my $self  = shift;
    my $block = shift;
    my @output;
    
    my @properties = qw(
            caption-side    table-layout  border-collapse
            border-spacing  empty-cells
        );
    
    foreach my $property ( @properties ) {
        my $value = $block->{ $property };
        
        push @output, sprintf $self->output_format, "${property}:", $value
            if defined $value;
    }
    
    return @output;
}

1;
