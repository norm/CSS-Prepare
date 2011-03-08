package CSS::Prepare::Plugin::TestPlugins;

sub expand {
    my $self      = shift;
    my $property  = shift;
    my $value     = shift;
    my $selectors = shift;
    
    return
        unless $property eq '-cp-test-plugins';
    
    # test replacing, appending to the current block
    # and appending an entirely new block
    return [{ property => 'plugin', value => $value }],
           [{ property => 'plugin', value => 'thanks' }],
           [{
                block => { 'plugin' => 'appended' },
                selectors => $selectors,
           }],
}
sub parse {
    my $self        = shift;
    my $has_hack    = shift;
    my $location    = shift;
    my %declaration = @_;
    
    my $property = $declaration{'property'};
    my $value    = $declaration{'value'};
    my %canonical;
    my @errors;
    
    if ( 'plugin' eq $property ) {
        if ( 'thanks' eq $value ) {
            $canonical{'plugin'} = $value
        }
        else {
            push @errors, {
                    error => "invalid plugin value '$value'"
                };
        }
    }
    
    return \%canonical, \@errors;
}
sub output {
    my $self  = shift;
    my $block = shift;
    
    my @output;
    
    my $value = $block->{'plugin'};
    push @output, sprintf $self->output_format, "plugin:", $value
        if defined $value;
    
    return @output;
}

1;
