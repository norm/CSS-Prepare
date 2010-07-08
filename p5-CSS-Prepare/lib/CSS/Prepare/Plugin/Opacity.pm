package CSS::Prepare::Plugin::Opacity;

use Modern::Perl;
use CSS::Prepare::Property::Expansions;
use CSS::Prepare::Property::Values;

sub expand {
    my $self     = shift;
    my $property = shift;
    my $value    = shift;
    
    if ( '-cp-opacity' eq $property ) {
        my $ms_opacity    = $value * 100;
        my $ms_filter     = 'progid:DXImageTransform.Microsoft.'
                            . "Alpha(Opacity=${ms_opacity})";
        my $legacy_filter = "alpha(opacity=${ms_opacity})";
        
        return [
                {
                    property => 'opacity',
                    value    => $value,
                },
                {
                    property => '-ms-filter',
                    value    => $ms_filter,
                },
                {
                    property => '*filter',
                    value    => $legacy_filter,
                },
            ];
    }
    
    return;
}
sub output {
    my $self  = shift;
    my $block = shift;
    
    my @output;
    my $value = $block->{'opacity'};
    push @output, sprintf $self->output_format, 'opacity:', $value
        if defined $value;
    
    return @output;
}
sub parse {}

1;

__END__

=head1 -cp-opacity

The meta-property C<-cp-opacity> will be expanded to provide opacity values
that are valid for browsers that understand CSS3 (C<opacity>) and versions
of Internet Explorer, using C<*filter> and C<-ms-filter>. For example, an
input of:

    #overlay { -cp-opacity: 0.5; }

will be output as:

    #overlay {
        -ms-filter: progid:DXImageTransform.Microsoft.Alpha(Opacity=50);
        opacity:    0.5;
        *filter:    alpha(opacity=50);
    }
