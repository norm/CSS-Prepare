package CSS::Prepare::Property::Text;

use Modern::Perl;
use CSS::Prepare::Property::Values;



sub parse {
    my %declaration = @_;
    
    my $property = $declaration{'property'};
    my $value    = $declaration{'value'};
    my %canonical;
    
    given ( $property ) {
        when ( 'text-indent'     ) { $canonical{ $property } = $value; }
        when ( 'text-align'      ) { $canonical{ $property } = $value; }
        when ( 'text-decoration' ) { $canonical{ $property } = $value; }
        when ( 'letter-spacing'  ) { $canonical{ $property } = $value; }
        when ( 'word-spacing'    ) { $canonical{ $property } = $value; }
        when ( 'text-transform'  ) { $canonical{ $property } = $value; }
        when ( 'white-space'     ) { $canonical{ $property } = $value; }
    }
    
    return %canonical;
}

1;
