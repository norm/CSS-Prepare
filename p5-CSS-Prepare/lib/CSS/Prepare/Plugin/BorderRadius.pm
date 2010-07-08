package CSS::Prepare::Plugin::BorderRadius;

use Modern::Perl;
use CSS::Prepare::Property::Expansions;
use CSS::Prepare::Property::Values;

my $get_border_radius_value = qr{ 
        (?'h1' $individual_border_radius_value )
        (?: \s+ (?'h2' $individual_border_radius_value ) )?
        (?: \s+ (?'h3' $individual_border_radius_value ) )?
        (?: \s+ (?'h4' $individual_border_radius_value ) )?
        (?:
            \s* / \s*
            (?'v1' $individual_border_radius_value )
            (?: \s+ (?'v2' $individual_border_radius_value ) )?
            (?: \s+ (?'v3' $individual_border_radius_value ) )?
            (?: \s+ (?'v4' $individual_border_radius_value ) )?
        )?
    }x;



sub expand {
    my $self     = shift;
    my $property = shift;
    my $value    = shift;
    
    # individual directions
    foreach my $corner ( @standard_corners ) {
        if ( "-cp-border-${corner}-radius" eq $property ) {
            return expand_vendor_properties( $corner, $value );
        }
    }
    if ( '-cp-border-radius' eq $property ) {
        if ( $value =~ m{^ $get_border_radius_value $}x ) {
            my %match = %+;
            
            my @matches;
            map { push @matches, $match{$_} if defined $match{$_} }
                qw( h1 h2 h3 h4 );
            my @horizontal = expand_corner_values( @matches );
            
            undef @matches;
            map { push @matches, $match{$_} if defined $match{$_} }
                qw( v1 v2 v3 v4 );
            my @vertical = expand_corner_values( @matches );
            
            my @return;
            foreach my $corner ( @standard_corners ) {
                my $value = shift( @horizontal )
                            . ( defined $vertical[0]
                                    ? ' ' . shift( @vertical )
                                    : ''
                              );
                
                my $values = expand_vendor_properties( $corner, $value );
                push @return, @$values;
            }
            
            return \@return;
        }
    }
    
    return;
}
sub output {
    my $self  = shift;
    my $block = shift;
    
    my @output;
    
    # do this for "-moz-border-radius"
    my @radii;
    foreach my $corner ( @standard_corners ) {
        my $moz_corner = $corner;
           $moz_corner =~ s{-}{};
        
        my $key   = "-moz-border-radius-${moz_corner}";
        my $value = $block->{ $key };
        
        push @radii,
            sprintf $self->output_format, "${key}:", $value
                if defined $value;
    }
    if ( 4 == scalar @radii ) {
        my( $h_array, $v_array ) = get_corner_values( $block, 'moz' );
        
        my $horizontal = collapse_corner_values( @$h_array );
        my $vertical   = collapse_corner_values( @$v_array );
        my $value      = $horizontal . ( $vertical ? " / ${vertical}" : '' );
        
        push @output, 
            sprintf $self->output_format, "-moz-border-radius:", $value;
    }
    else {
        push @output, @radii;
    }
    
    # do this for "-webkit-border-radius"
    undef @radii;
    foreach my $corner ( @standard_corners ) {
        my $key   = "-webkit-border-${corner}-radius";
        my $value = $block->{ $key };
        
        push @radii,
            sprintf $self->output_format, "${key}:", $value
                if defined $value;
    }
    if ( 4 == scalar @radii ) {
        my( $h_array, $v_array ) = get_corner_values( $block, 'webkit' );
        
        my $horizontal = collapse_corner_values( @$h_array );
        my $vertical   = collapse_corner_values( @$v_array );
        my $value      = $horizontal . ( $vertical ? " / ${vertical}" : '' );
        
        push @output, 
            sprintf $self->output_format, "-webkit-border-radius:", $value;
    }
    else {
        push @output, @radii;
    }
    
    # remove the vendor prefixes from $block, or
    # they will reoccur thanks to Vendor.pm
    foreach my $corner ( @standard_corners ) {
        my $moz_corner = $corner;
           $moz_corner =~ s{-}{};
        
       delete $block->{"-moz-border-radius-${moz_corner}"};
       delete $block->{"-webkit-border-${corner}-radius"};
    }
    
    return @output;
}
sub parse {}

sub expand_vendor_properties {
    my $corner = shift;
    my $value  = shift;
    
    my $moz_corner  = $corner;
       $moz_corner =~ s{-}{};
    
    return [
            {
                property => "-webkit-border-${corner}-radius",
                value    => $value,
            },
            {
                property => "-moz-border-radius-${moz_corner}",
                value    => $value,
            },
            {
                property => "border-${corner}-radius",
                value    => $value,
            },
        ];
}

1;


=pod

=head1 -cp-border-radius

The meta-properties C<-cp-border-radius>, C<-cp-border-top-left-radius>,
C<-cp-border-top-right-radius>, C<-cp-border-bottom-right-radius> and
C<-cp-border-bottom-left-radius> will be expanded to the appropriate
declarations for the three properties C<border-radius>, C<-moz-border-radius>
and C<-webkit-border-radius>. For example, an input of:

    #masthead { -cp-border-top-left-radius: 5px 2px; }

will be output as:

    #masthead {
        border-top-left-radius: 5px 2px;
        -moz-border-radius-topleft: 5px 2px;
        -webkit-border-top-left-radius: 5px 2px;
    }
