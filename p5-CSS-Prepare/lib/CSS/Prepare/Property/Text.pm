package CSS::Prepare::Property::Text;

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
            return $is_valid;
        };
    
    &$valid_property_or_error( 'letter_spacing' )
        if 'letter-spacing' eq $property;
    
    &$valid_property_or_error( 'text_align' )
        if 'text-align' eq $property;
    
    &$valid_property_or_error( 'text_decoration' )
        if 'text-decoration' eq $property;
    
    &$valid_property_or_error( 'text_indent' )
        if 'text-indent' eq $property;
    
    &$valid_property_or_error( 'text_transform' )
        if 'text-transform' eq $property;
    
    &$valid_property_or_error( 'white_space' )
        if 'white-space' eq $property;
    
    &$valid_property_or_error( 'word_spacing' )
        if 'word-spacing' eq $property;
    
    &$valid_property_or_error( 'content' )
        if 'content' eq $property;
    
    return \%canonical, \@errors;
}
sub output {
    my $self  = shift;
    my $block = shift;
    
    my @properties = qw(
                         letter-spacing  text-align   text-decoration
            text-indent  text-transform  white-space  word-spacing
        );
    my @output;
    
    foreach my $property ( @properties ) {
        my $value = $block->{ $property };

        push @output, sprintf $self->output_format, "${property}:", $value
            if defined $value;
    }
    
    return @output;
}

1;
