package CSS::Prepare::Property::Expansions;

use Modern::Perl;
use Exporter;

our @ISA    = qw( Exporter );
our @EXPORT = qw( expand_trbl_shorthand );



sub expand_trbl_shorthand {
    my $pattern = shift;
    my $value   = shift;
    
    my @values = split( m{\s+}, $value );
    my %values;
    
    given ( $#values ) {
        when ( 0 ) {
            # top/bottom/left/right shorthand
            foreach my $subproperty qw( top bottom left right ) {
                my $key = sprintf $pattern, $subproperty;
                $values{ $key } = $values[0];
            }
        }
        when ( 1 ) {
            # top/bottom and left/right shorthand
            foreach my $subproperty qw ( top bottom ) {
                my $key = sprintf $pattern, $subproperty;
                $values{ $key } = $values[0];
            }
            foreach my $subproperty qw ( left right ) {
                my $key = sprintf $pattern, $subproperty;
                $values{ $key } = $values[1];
            }
        }
        when ( 2 ) {
            # top, left/right and bottom shorthand
            my $key = sprintf $pattern, 'top';
            $values{ $key }    = $values[0];
            $key = sprintf $pattern, 'bottom';
            $values{ $key } = $values[2];
            foreach my $subproperty qw ( left right ) {
                $key = sprintf $pattern, $subproperty;
                $values{ $key } = $values[1];
            }
        }
        when ( 3 ) {
            # top, right, bottom and left shorthand
            my $key = sprintf $pattern, 'top';
            $values{ $key } = $values[0];
            $key = sprintf $pattern, 'bottom';
            $values{ $key } = $values[2];
            $key = sprintf $pattern, 'left';
            $values{ $key } = $values[3];
            $key = sprintf $pattern, 'right';
            $values{ $key } = $values[1];
        }
    }
    
    return %values;
}

1;
