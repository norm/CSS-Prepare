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

1;
