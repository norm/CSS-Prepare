package CSS::Prepare::Property::Hacks;

use Modern::Perl;



sub output {
    my $block = shift;
    
    my $output;
    foreach my $property ( keys %{$block} ) {
        if ( $property =~ m{^[_\*]} ) {
            $output .= "$property:$block->{$property};";
        }
    }
    
    return $output;
}

1;
