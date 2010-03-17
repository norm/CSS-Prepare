package CSS::Prepare::Property::Padding;

use Modern::Perl;
use CSS::Prepare::Property::Expansions;



sub parse {
    my %declaration = @_;
    
    my $property = $declaration{'property'};
    my $value    = $declaration{'value'};
    my %canonical;
    my @errors;
    
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
    
    return \%canonical, \@errors;
}
sub output {
    my $block = shift;
    
    my @padding;
    my @output;
    
    foreach my $direction qw( top right bottom left ) {
        my $key = "padding-${direction}";
        my $value = $block->{ $key };
        
        push @padding, "padding-${direction}:${value};"
            if defined $value;
    }
    
    if ( 4 == scalar @padding ) {
        push @output, collapse_trbl_shorthand( 'padding', $block );
    }
    else {
        push @output, @padding;
    }
    
    return @output;
}

1;
