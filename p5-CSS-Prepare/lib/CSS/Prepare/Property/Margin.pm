package CSS::Prepare::Property::Margin;

use Modern::Perl;
use CSS::Prepare::Property::Expansions;



sub parse {
    my %declaration = @_;
    
    my $property = $declaration{'property'};
    my $value    = $declaration{'value'};
    my %canonical;
    my @errors;
    
    given ( $property ) {
        when ( 'margin' ) {
            %canonical = expand_trbl_shorthand(
                    'margin-%s',
                    $value
                );
        }
        when ( 'margin-top'    ) { $canonical{ $property } = $value; }
        when ( 'margin-bottom' ) { $canonical{ $property } = $value; }
        when ( 'margin-left'   ) { $canonical{ $property } = $value; }
        when ( 'margin-right'  ) { $canonical{ $property } = $value; }
    }
    
    return \%canonical, \@errors;
}
sub output {
    my $block = shift;
    
    my @directions = qw( top right bottom left );
    my $count      = 0;
    my $output;
    foreach my $direction ( @directions ) {
        my $key = "margin-${direction}";
        
        if ( defined $block->{ $key } ) {
            my $value = $block->{ $key };
            $output .= "margin-${direction}:${value};";
            $count++;
        }
    }
    
    if ( 4 == $count ) {
        $output = collapse_trbl_shorthand( 'margin', $block );
    }
    
    return $output;
}

1;
