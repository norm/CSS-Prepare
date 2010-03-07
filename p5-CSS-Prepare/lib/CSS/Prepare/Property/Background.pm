package CSS::Prepare::Property::Background;

use Modern::Perl;

# use CSS::Prepare::Property::Expansions;
use CSS::Prepare::Property::Values;



sub parse {
    my %declaration = @_;
    
    my $property = $declaration{'property'};
    my $value    = $declaration{'value'};
    my %canonical;
    
    given ( $property ) {
        when ( 'background-color'      ) { $canonical{ $property } = $value; }
        when ( 'background-image'      ) { $canonical{ $property } = $value; }
        when ( 'background-repeat'     ) { $canonical{ $property } = $value; }
        when ( 'background-attachment' ) { $canonical{ $property } = $value; }
        when ( 'background-position'   ) { $canonical{ $property } = $value; }
        
        # allow for the correct spelling of colour
        when ( 'background-colour' ) { 
            $canonical{'background-color'} = $value; 
        }
        
        when ( 'background' ) {
            my @partials = split ( m{\s+}, $value );
            
            foreach my $partial ( @partials ) {
                if ( is_colour_value( $partial ) ) {
                    $canonical{'background-color'} = $partial;
                }
                elsif ( is_url_value( $partial ) ) {
                    $canonical{'background-image'} = $partial;
                }
                elsif ( is_background_repeat_value( $partial ) ) {
                    $canonical{'background-repeat'} = $partial;
                }
                elsif ( is_background_attachment_value( $partial ) ) {
                    $canonical{'background-attachment'} = $partial;
                }
                else {
                    $canonical{'background-position'} .= "$partial ";
                }
            }
        }
    }
    
    # simple concatenation leaves us with extra space, remove it
    if ( defined $canonical{'background-position'} ) {
        $canonical{'background-position'} =~ s{ \s+ $}{}x;
    }
    
    return %canonical;
}

sub output {
    my $block = shift;
    
    my @properties = qw( background-color background-image background-repeat
                         background-attachment background-position );
    my $count = 0;
    my @values;
    my $output;
    
    foreach my $property ( @properties ) {
        if ( defined $block->{ $property } ) {
            push @values, $block->{ $property };
            $output = $property;
            $count++;
        }
    }
    
    if ( 1 == $count ) {
        my $value = $block->{ $output };
        $output .= ":${value};";
    }
    elsif ( 2 <= $count ) {
        my $value = join ' ', @values;
        $output = "background:$value;";
    }
    
    return $output;
}

1;
