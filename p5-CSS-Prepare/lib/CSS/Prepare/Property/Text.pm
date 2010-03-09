package CSS::Prepare::Property::Text;

use Modern::Perl;
use CSS::Prepare::Property::Values;



sub parse {
    my %declaration = @_;
    
    my $property = $declaration{'property'};
    my $value    = $declaration{'value'};
    my %canonical;
    my @errors;
    
    given ( $property ) {
        when ( 'letter-spacing'  ) { $canonical{ $property } = $value; }
        when ( 'text-align'      ) { $canonical{ $property } = $value; }
        when ( 'text-decoration' ) { $canonical{ $property } = $value; }
        when ( 'text-indent'     ) { $canonical{ $property } = $value; }
        when ( 'text-transform'  ) { $canonical{ $property } = $value; }
        when ( 'white-space'     ) { $canonical{ $property } = $value; }
        when ( 'word-spacing'    ) { $canonical{ $property } = $value; }
        when ( 'content'         ) { $canonical{ $property } = $value; }
    }
    
    return \%canonical, \@errors;
}
sub output {
    my $block = shift;
    
    my @properties = qw(
            content      letter-spacing  text-align   text-decoration
            text-indent  text-transform  white-space  word-spacing
        );
    my $output;
    
    foreach my $property ( @properties ) {
        my $value = $block->{ $property };

        $output .= "$property:$value;"
            if defined $value;
    }
    
    return $output;
}

1;
