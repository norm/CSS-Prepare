package CSS::Prepare;

use strict;
use warnings;

use Exporter;

use CSS::Prepare::Parse;



# boilerplate new function
sub new {
    my $proto = shift;
    my $args  = shift;
    
    my $class = ref $proto || $proto;
    my $self  = {};
    bless $self, $class;
    
    return $self;
}



sub parse_string {
    my $self   = shift;
    my $string = shift;
    
    return CSS::Prepare::Parse::parse( $string )
}

1;
