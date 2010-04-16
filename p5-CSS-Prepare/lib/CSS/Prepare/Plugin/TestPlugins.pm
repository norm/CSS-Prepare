package CSS::Prepare::Plugin::TestPlugins;

sub expand {
    my $self     = shift;
    my $property = shift;
    my $value    = shift;
    
    return
        unless $property eq '-cp-test-plugins';
    
    return [{ property => 'plugin', value => $value }];
}
sub parse {
    my $self        = shift;
    my $has_hack    = shift;
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
