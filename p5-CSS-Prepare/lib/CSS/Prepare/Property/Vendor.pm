package CSS::Prepare::Property::Vendor;

use Modern::Perl;



sub parse {
    my $self        = shift;
    my $has_hack    = shift;
    my $location    = shift;
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
    my $self  = shift;
    my $block = shift;
    
    my @output;
    foreach my $property ( keys %{$block} ) {
        if ( $property =~ m{^-} ) {
            push @output, sprintf $self->output_format, 
                                      "${property}:", $block->{ $property };
        }
    }
    
    return @output;
}

1;
