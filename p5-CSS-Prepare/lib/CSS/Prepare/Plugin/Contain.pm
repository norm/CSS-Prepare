package CSS::Prepare::Plugin::Contain;

# TODO
#   -   how to inject styles for _DIFFERENT_ selectors? (append to the end of
#       the current block, which helps with the following)
#   -   stop optimise from turning display:inline; display:block; into
#       one rule by putting it within two chunks ($prep->add_chunk()?)

use Modern::Perl;
use CSS::Prepare::Property::Expansions;
use CSS::Prepare::Property::Values;

my $contain_value = qr{ 
            (?'overflow' overflow )
        |
            (?'easy' easy ) 
            (?: \s+ (?'easytype' valid | hack ) )?
    }x;



sub expand {
    my $self      = shift;
    my $property  = shift;
    my $value     = shift;
    my $selectors = shift;
    
    return
        unless $property eq '-cp-contain';
    
    # validate the value, and if not understood, just pass it through as
    # contain: $value
    return 
        unless $value =~ m{$contain_value};
    my %match = %+;
    
    return [{ property => 'overflow', value =>  'auto' }]
        if defined $match{'overflow'};
    
    # mungle the selectors
    my @after_selectors;
    map { push @after_selectors, "${_}:after" } @$selectors;
    
    if ( defined $match{'easytype'} && $match{'easytype'} eq 'valid' ) {
        return
            [{ property => 'display', value => 'inline-block' }],
            [],
            [
                {
                    block => {
                        'content'    => '"."',
                        'display'    => 'block',
                        'height'     => '0',
                        'clear'      => 'both',
                        'visibility' => 'hidden',
                    },
                    selectors => \@after_selectors,
                },
                {   type => 'boundary' },
                {
                    block => { 'display' => 'block' },
                    selectors => $selectors,
                }
            ];
    }
    else {
        return
            [{ property => '_zoom', value => '1' }],
            [],
            [
                {
                    block => {
                        'content'    => '"."',
                        'display'    => 'block',
                        'height'     => '0',
                        'clear'      => 'both',
                        'visibility' => 'hidden',
                    },
                    selectors => \@after_selectors,
                },
            ];
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

=head1 -cp-contain

When every child of an element has been floated, that element will collapse to
nothing. This is sometimes undesirable for styling, and there are two
techniques to restore the element without the need to add more HTML. The two
main values that C<-cp-contain> accepts are named after the techniques:

=over

=item overflow

Applying C<overflow: hidden> to the element will cause it to contain the
floated children. This method is the simplest, although it does have the 
occasional side-effect (it stops margins from collapsing, for example).

    #content { -cp-contain: overflow; }

becomes

    #content { overflow: hidden; }

=item easy

Applying content to the :after pseudo-property of the element and then styling
it to be invisible. This generates a lot more CSS, but has no side-effects
other than containing the floats.

There are two ways of fixing this in versions of Internet Explorer that do not
support :after, one that generates valid CSS and one that uses the C<zoom:1>
hack. These can be selected by adding a second keyword of "valid" or "hack".
Without either, the "hack" method is used as it is shorter.

    #content { -cp-contain: easy valid; }
    /* -- */
    #nav     { -cp-contain: easy hack; }

becomes

    #content { display: inline; }
    #content:after {
        content:    ".";
        display:    block;
        height:     0;
        clear:      both;
        visibility: hidden;
    }
    #content { display: block; }
    /* -- */
    #content { _zoom: 1; }
    #content:after {
        content:    ".";
        display:    block;
        height:     0;
        clear:      both;
        visibility: hidden;
    }
