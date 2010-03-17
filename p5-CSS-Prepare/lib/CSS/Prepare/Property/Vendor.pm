package CSS::Prepare::Property::Vendor;

use Modern::Perl;



sub parse {
    my %declaration = @_;
    
    my $property = $declaration{'property'};
    my $value    = $declaration{'value'};
    my %canonical;
    my @errors;
    
    if ( $property =~ m{^-} ) {
        $canonical{ $property } = $value;
    }
    
    return \%canonical, [];
}
sub output {
    my $block = shift;
    
    my @output;
    foreach my $property ( keys %{$block} ) {
        if ( $property =~ m{^-} ) {
            push @output, "$property:$block->{$property};";
        }
    }
    
    return @output;
}

1;
