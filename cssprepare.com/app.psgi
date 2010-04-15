use Modern::Perl;

use CSS::Prepare;
use Digest::SHA1        qw( sha1_base64 );
use HTML::Entities;
use IO::All             -utf8;
use Plack::App::File;
use Plack::Builder;
use Plack::Request;
use Pod::POM;
use Pod::POM::View::InlineHTML;
use Pod::POM::View::HTML;
use Storable;
use Text::Template;

sub render {
    my $template = shift;
    my $data     = shift;
    
    my $output = render_template( $template, $data );
    
    return [
               200,
               [
                   'Content-Type'   => 'text/html; charset=utf-8',
                   'Content-Length' => length( $output ),
               ],
               [ $output ],
           ];
}
sub render_css {
    my $css = shift;
    
    return [
            200,
            [
                'Content-Type' => 'text/css; charset=utf-8',
                'content-Length' => length( $css ),
            ],
            [ $css ],
        ];
}
sub render_404 {
    my $output = render_template( '404.html', {} );
    
    return [
               404,
               [
                   'Content-Type'   => 'text/html; charset=utf-8',
                   'Content-Length' => length( $output ),
               ],
               [ $output ],
           ];
}
sub render_template {
    my $filename = shift;
    my $data     = shift;

    my $expander = Text::Template->new(
            TYPE       => 'FILE',
            SOURCE     => "templates/$filename",
            DELIMITERS => [ '{{', '}}' ],
        );
    
    return $expander->fill_in( HASH => $data );
}
sub redirect {
    my $url = shift;
    
    return [ 302, [ 'Location' => $url ], [], ];
}

sub process_css {
    my $sha1     = shift;
    my $optimise = shift;
    
    my $css = get_css( $sha1 );
    return unless defined $css;
    
    my $preparer  = CSS::Prepare->new();
    my @structure = $preparer->parse_string( $css );
    
    my @errors;
    foreach my $block ( @structure ) {
        my $selector = '';
        $selector = join ', ', @{$block->{'selectors'}} 
            if defined $block->{'selectors'};
        
        foreach my $error ( @{$block->{'errors'}} ) {
            my( $level, $text ) = each %$error;
            
            push @errors, {
                    level    => $level,
                    selector => $selector,
                    text     => $text,
                    original => $block->{'original'},
                };
        }
    }
    
    my $errors_file = get_filename( $sha1, 'errors' );
    store \@errors, $errors_file;
    
    @structure = $preparer->optimise( @structure )
        if $optimise;
    
    my $output = $preparer->output_as_string( @structure );
    my $type   = $optimise ? 'optimised' : 'output';
    my $store = get_filename( $sha1, "${type}.css" );
    $output > io $store;
}
sub get_filename {
    my $sha1     = shift;
    my $filename = shift
                   // 'unknown_file';
    
    return unless defined $sha1;
    return unless $sha1 =~ m{ [A-Za-z0-9+_]{27} }x;
    
    my $base   = $ENV{'CSS_PREPARE_STORE'}
                 // 'store/';
    my $subdir = substr( $sha1, 0, 2 );
    my $target = "${base}/${subdir}/${sha1}/${filename}";
    
    mkdir "${base}";
    mkdir "${base}/${subdir}";
    mkdir "${base}/${subdir}/${sha1}";
    
    return $target;
}
sub store_css {
    my $css = shift;
    
    my $sha1   = sha1_base64( $css );
       $sha1  =~ s{/}{_}g;
    my $target = get_filename( $sha1, 'original.css' );
    $css > io $target;
    
    return $sha1;
}
sub get_css {
    my $sha1 = shift;
    my $type = shift // 'original';
    
    my $target = get_filename( $sha1, "${type}.css" );
    my $io     = io $target;
    
    return unless $io->exists;
    return $io->all;
}
sub get_output_css {
    my $sha1 = shift;
    my $type = shift // 'original';
    
    my $css = get_css( $sha1, $type );
    
    return encode_entities( $css );
}
sub get_errors {
    my $sha1 = shift;
    
    my $errors_file = get_filename( $sha1, 'errors' );
    return retrieve $errors_file;
}
sub get_output_errors {
    my $sha1 = shift;
    
    my $errors = get_errors( $sha1 );
    my @output;
    
    foreach my $error ( @{$errors} ) {
        $error->{'selector'} = encode_entities( $error->{'selector'} );
        $error->{'text'}     = encode_entities( $error->{'text'} );
    }
    
    return $errors;
}
sub is_flagged {
    my $sha1 = shift;
    
    my $target = get_filename( $sha1, 'flagged' );
    return ( -f $target );
}
sub pod_to_html {
    my $page = shift;
    
    # state %pod_cache;
    # my $html = $pod_cache{ $page };
    
    # if ( !defined $html ) {
        my %PAGES = (
                default        => 'lib/CSS/Prepare/Manual/Introduction.pod',
                deploying      => 'lib/CSS/Prepare/Manual/Deploying.pod',
                features       => 'lib/CSS/Prepare/Manual/Features.pod',
                hacks          => 'lib/CSS/Prepare/Manual/Hacks.pod',
                hierarchy      => 'lib/CSS/Prepare/Manual/Hierarchy.pod',
                optimising     => 'lib/CSS/Prepare/Manual/Optimising.pod',
                'command-line' => 'bin/cssprepare',
            );
        my $file   = $PAGES{ $page }
                     // $PAGES{'default'};
        
        my $parser = Pod::POM->new();
        my $pom    = $parser->parse_file( $file );
        my $viewer = Pod::POM::View::InlineHTML->new( header_level => 2 );
        
        my $html = $viewer->print( $pom );
        # $pod_cache{ $page } = $html;
    # }
    
    return $html;
}

my $problems_page = sub { return render( 'problems.html', {} ); };
my $documentation_page = sub {
    my $environment = shift;
    my $request     = Plack::Request->new( $environment );
    
    my( undef, $page ) = split m{/}, $request->path_info;
    $page = 'introduction'
        unless $page;
    
    return render(
            'documentation.html',
            {
                page    => $page,
                content => pod_to_html( $page ),
            }
        );
};
my $home_page = sub { 
    my $environment = shift;
    my $request     = Plack::Request->new( $environment );
    
    return render( 'home.html', {} )
        if '/' eq $request->path_info;
    return render_404();
};
my $new_css = sub {
    my $environment = shift;
    my $request     = Plack::Request->new( $environment );
    
    if ( 'POST' eq $request->method ) {
        my $params = $request->parameters;
        
        my $css      = $params->{'css'};
        my $optimise = $params->{'optimise'} // 0;
        
        # normalise line endings
        $css =~ s{\r\n}{\n}sg;
        $css =~ s{\r}{\n}sg;
        
        my $sha1 = store_css( $css );
        my $redirect = "/css/${sha1}/"
                       . ( $optimise ? 'optimise' : '' );
        
        return redirect( $redirect );
    }
    
    return redirect( '/' );
};
my $styles = sub {
    my $environment = shift;
    my $request     = Plack::Request->new( $environment );
    
    my( undef, $sha1, $optimise ) = split m{/}, $request->path_info;
    
    my $css = get_output_css( $sha1 );
    return render_404() 
        unless defined $css;
    
    process_css( $sha1, $optimise );
    my $type    = $optimise ? 'optimised' : 'output';
    my $output  = get_output_css( $sha1, $type );
    my $errors  = get_output_errors( $sha1 );
    my $flagged = is_flagged( $sha1 );
    
    $output =~ s{^(.*)$}{<span class="line">$1</span>}gm;
    
    return render(
            'css.html',
            {
                css         => $css,
                output      => $output,
                optimise    => $optimise,
                errors      => $errors,
                flagged     => $flagged,
                sha1        => $sha1,
                error_count => scalar @$errors,
            },
        );
};
my $raw_css = sub {
    my $environment = shift;
    my $request     = Plack::Request->new( $environment );
    
    my( undef, $sha1, $filename ) = split m{/}, $request->path_info;
    
    my $target = get_filename( $sha1, $filename );
    my $css    = get_css( $sha1 );
    
    if ( defined $css ) {
        # only try processing CSS that already exists as original.css
        if ( 'optimised.css' eq $filename ) {
            process_css( $sha1, 1 );
            $css = get_css( $sha1, 'optimised' );
        }
        elsif ( 'output.css' eq $filename ) {
            process_css( $sha1, 0 );
            $css = get_css( $sha1, 'output' );
        }
    }
    
    return render_css( $css )
        if defined $css;
    return render_404();
};
my $flag_css = sub {
    my $environment = shift;
    my $request     = Plack::Request->new( $environment );
    
    if ( 'POST' eq $request->method ) {
        my $params = $request->parameters;
        
        my $sha1 = $params->{'sha1'};
        my $flag = $params->{'flag'};
        
        if ( defined $flag && defined $sha1 ) {
            my $target = get_filename( $sha1, 'original.css' );
            if ( -f $target ) {
                $target = get_filename( $sha1, 'flagged' );
                
                my $io = io $target;
                
                $io->touch()
                    if 'flag' eq $flag;
                $io->unlink()
                    if 'flag' ne $flag;
            }
        }
        
        my $redirect = "/css/${sha1}/";
        return redirect( $redirect );
    }
    
    return redirect( '/' );
};

builder {
    mount "/static"        => Plack::App::File->new( root => "site" );
    mount "/documentation" => $documentation_page;
    mount "/problems"      => $problems_page;
    mount "/css"           => $styles;
    mount "/raw"           => $raw_css;
    mount "/flag"          => $flag_css;
    mount "/new"           => $new_css;
    mount "/"              => $home_page;
};
