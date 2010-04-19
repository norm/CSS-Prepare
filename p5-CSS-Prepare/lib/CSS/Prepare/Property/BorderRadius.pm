package CSS::Prepare::Property::BorderRadius;

use Modern::Perl;
use CSS::Prepare::Property::Expansions;
use CSS::Prepare::Property::Values;

my $get_border_radius_values = qr{ 
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



sub parse {
    my $self        = shift;
    my $has_hack    = shift;
    my %declaration = @_;
    
    my $property = $declaration{'property'};
    my $value    = $declaration{'value'};
    my %canonical;
    my @errors;
    
    foreach my $corner ( @standard_corners ) {
        my $check = "border-${corner}-radius";
        
        if ( $check eq $property ) {
            if ( $value =~ m{^ $border_radius_corner_value $}x ) {
                $canonical{ $check } = $value;
            }
            else {
                push @errors, {
                        error => "invalid ${check} property: '${value}'"
                    };
                
            }
        }
    }
    
    if ( 'border-radius' eq $property ) {
        if ( $value =~ m{^ $get_border_radius_values $}x ) {
            my %match = %+;
            
            my @matches;
            map { push @matches, $match{$_} if defined $match{$_} }
                qw( h1 h2 h3 h4 );
            my @horizontal = expand_corner_values( @matches );
            
            undef @matches;
            map { push @matches, $match{$_} if defined $match{$_} }
                qw( v1 v2 v3 v4 );
            my @vertical = expand_corner_values( @matches );
            
            foreach my $corner ( @standard_corners ) {
                my $value = shift( @horizontal )
                            . ( defined $vertical[0]
                                    ? ' ' . shift( @vertical )
                                    : ''
                              );
                
                $canonical{"border-${corner}-radius"} = $value;
            }
        }
        else {
            push @errors, {
                    error => "invalid border-radius property: '${value}'"
                };
        }
    }
    
    return \%canonical, \@errors;
}
sub output {
    my $self  = shift;
    my $block = shift;
    
    my @output;
    my @radii;
    foreach my $corner ( @standard_corners ) {
        my $key   = "border-${corner}-radius";
        my $value = $block->{ $key };
        
        push @radii,
            sprintf $self->output_format, "${key}:", $value
                if defined $value;
    }
    
    if ( 4 == scalar @radii ) {
        my( $h_array, $v_array ) = get_corner_values( $block, 'css3' );
        
        my $horizontal = collapse_corner_values( @$h_array );
        my $vertical   = collapse_corner_values( @$v_array );
        my $value      = $horizontal . ( $vertical ? " / ${vertical}" : '' );
        
        push @output, sprintf $self->output_format, "border-radius:", $value;
    }
    else {
        push @output, @radii;
    }
    
    return @output;
}

1;
