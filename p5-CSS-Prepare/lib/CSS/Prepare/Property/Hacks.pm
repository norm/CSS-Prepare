package CSS::Prepare::Property::Hacks;

use Modern::Perl;

my @COMMON_HACK_PROPERTIES = qw( zoom filter );



sub parse {
    my $self        = shift;
    my $has_hack    = shift;
    my $location    = shift;
    my %declaration = @_;
    
    my $property = $declaration{'property'};
    my $value    = $declaration{'value'};
    my %canonical;
    my @errors;
    
    if ( $has_hack ) {
        foreach my $hack ( @COMMON_HACK_PROPERTIES ) {
            $canonical{ $hack } = $value
                if $property eq $hack;
        }
    }
    
    return \%canonical, \@errors;
}

sub output {
    my $self  = shift;
    my $block = shift;
    
    my @output;
    foreach my $property ( keys %{$block} ) {
        if ( $property =~ m{^[_\*]} ) {
            push @output, sprintf $self->output_format, 
                              "${property}:", $block->{ $property };
        }
    }
    
    foreach my $hack ( @COMMON_HACK_PROPERTIES ) {
        my $value = $block->{ $hack };
        
        push @output, sprintf $self->output_format, "${hack}:", $value
            if defined $value;
    }
    
    return @output;
}

1;
