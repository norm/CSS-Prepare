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
    
    my @margin;
    my @output;
    
    foreach my $direction qw( top right bottom left ) {
        my $key = "margin-${direction}";
        my $value = $block->{ $key };
        
        push @margin, "margin-${direction}:${value};"
            if defined $value;
    }
    
    if ( 4 == scalar @margin ) {
        push @output, collapse_trbl_shorthand( 'margin', $block );
    }
    else {
        push @output, @margin;
    }
    
    return @output;
}

1;
