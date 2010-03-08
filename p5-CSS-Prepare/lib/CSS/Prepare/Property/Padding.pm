package CSS::Prepare::Property::Padding;

use Modern::Perl;
use CSS::Prepare::Property::Expansions;



sub parse {
    my %declaration = @_;
    
    my $property = $declaration{'property'};
    my $value    = $declaration{'value'};
    my %canonical;
    
    given ( $property ) {
        when ( 'padding' ) {
            %canonical = expand_trbl_shorthand(
                    'padding-%s',
                    $value
                );
        }
        when ( 'padding-top'    ) { $canonical{ $property } = $value; }
        when ( 'padding-bottom' ) { $canonical{ $property } = $value; }
        when ( 'padding-left'   ) { $canonical{ $property } = $value; }
        when ( 'padding-right'  ) { $canonical{ $property } = $value; }
    }
    
    return %canonical;
}
sub output {
    my $block = shift;
    
    my @directions = qw( top right bottom left );
    my $count      = 0;
    my $output;
    foreach my $direction ( @directions ) {
        my $key = "padding-${direction}";
        
        if ( defined $block->{ $key } ) {
            my $value = $block->{ $key };
            $output .= "padding-${direction}:${value};";
            $count++;
        }
    }
    
    if ( 4 == $count ) {
        $output = collapse_trbl_shorthand( 'padding', $block );
    }
    
    return $output;
}

1;
