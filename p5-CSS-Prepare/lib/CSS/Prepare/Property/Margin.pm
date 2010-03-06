package CSS::Prepare::Property::Margin;

use Modern::Perl;
use CSS::Prepare::Property::Expansions;



sub parse {
    my %declaration = @_;
    
    my $property = $declaration{'property'};
    my $value    = $declaration{'value'};
    my %canonical;
    
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
    
    return %canonical;
}

1;
