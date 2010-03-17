package CSS::Prepare::Property::Hacks;

use Modern::Perl;



sub parse {
    my %declaration = @_;
    
    my $property = $declaration{'property'};
    my $value    = $declaration{'value'};
    my %canonical;
    my @errors;
    
    if ( 'zoom' eq $property ) {
        $canonical{'zoom'} = $value;
    }
    
    return \%canonical, \@errors;
}

sub output {
    my $block = shift;
    
    my @output;
    foreach my $property ( keys %{$block} ) {
        if ( $property =~ m{^[_\*]} ) {
            push @output, "${property}:$block->{$property};";
        }
        
        if ( 'zoom' eq $property ) {
            push @output, "${property}:$block->{$property};";
        }
    }
    
    return @output;
}

1;
