package CSS::Prepare;

use Modern::Perl;

use CSS::Prepare::CSSGrammar;
use CSS::Prepare::Property::Background;
use CSS::Prepare::Property::Border;
use CSS::Prepare::Property::BorderRadius;
use CSS::Prepare::Property::Color;
use CSS::Prepare::Property::Effects;
use CSS::Prepare::Property::Font;
use CSS::Prepare::Property::Formatting;
use CSS::Prepare::Property::Generated;
use CSS::Prepare::Property::Hacks;
use CSS::Prepare::Property::Margin;
use CSS::Prepare::Property::Padding;
use CSS::Prepare::Property::Tables;
use CSS::Prepare::Property::Text;
use CSS::Prepare::Property::UI;
use CSS::Prepare::Property::Values;
use CSS::Prepare::Property::Vendor;
use Digest::SHA1        qw( sha1_hex );
use FileHandle;
use File::Basename;
use File::Path;
use List::Util          qw( first );
use Storable            qw( dclone );

use version;
our $VERSION = qv( 0.9.1 );

use constant MAX_REDIRECT       => 3;
use constant RE_IS_URL          => qr{^ http s? : // }x;
use constant RE_MATCH_HOSTNAME  => qr{^ ( http s? : // [^/]+ ) /? .* $}x;
use constant RE_MATCH_DIRECTORY => qr{^ (.*?) (?: / [^/]* )? $}x;
use constant NOT_VENDOR_PREFIX  => qw(
        background  border   empty    font  letter
        list        margin   padding  page  table
        text        unicode  white    z
    );

my @MODULES = qw(
        Background
        Border
        BorderRadius
        Color
        Effects
        Font
        Formatting
        Hacks
        Generated
        Margin
        Padding
        Tables
        Text
        UI
        Vendor
    );



sub new {
    my $class = shift;
    my %args  = @_;
    
    my $self = {
            hacks                => 1,
            extended             => 0,
            suboptimal_threshold => 10,
            http_timeout         => 30,
            pretty               => 0,
            assets_output        => undef,
            assets_base          => undef,
            status               => \&status_to_stderr,
            %args
        };
    bless $self, $class;
    
    my %http_providers = (
            lite => 'HTTP::Lite',
            lwp  => 'LWP::UserAgent',
        );
    
    # sort to prefer HTTP::Lite over LWP::UserAgent
    HTTP:
    foreach my $provider ( sort keys %http_providers ) {
        my $module = $http_providers{ $provider };
        
        eval "require $module";
        unless ($@) {
            $self->{'http_provider'} = $provider;
            last HTTP;
        }
    }
    
    # check for ability to use plugins
    if ( $self->support_extended_syntax() ) {
        eval "use Module::Pluggable require => 1;";
        unless ($@) {
            foreach my $plugin ( $self->plugins() ) {
                $self->{'has_plugins'} = 1;
            }
        }
    }
    
    return $self;
}
sub get_hacks {
    my $self = shift;
    return $self->{'hacks'};
}
sub set_hacks {
    my $self = shift;
    my $hacks = shift // 0;
    
    $self->{'hacks'} = $hacks;
}
sub support_hacks {
    my $self = shift;
    return $self->{'hacks'};
}
sub get_extended {
    my $self = shift;
    return $self->{'extended'};
}
sub set_extended {
    my $self     = shift;
    my $extended = shift // 0;
    
    $self->{'extended'} = $extended;
}
sub support_extended_syntax {
    my $self = shift;
    return $self->{'extended'};
}
sub get_suboptimal_threshold {
    my $self = shift;
    return $self->{'suboptimal_threshold'};
}
sub set_suboptimal_threshold {
    my $self     = shift;
    my $suboptimal_threshold = shift // 0;
    
    $self->{'suboptimal_threshold'} = $suboptimal_threshold;
}
sub suboptimal_threshold {
    my $self = shift;
    return $self->{'suboptimal_threshold'};
}
sub get_pretty {
    my $self = shift;
    return $self->{'pretty'};
}
sub set_pretty {
    my $self  = shift;
    my $value = shift;
    
    $self->{'pretty'} = $value;
}
sub pretty_output {
    my $self = shift;
    return $self->{'pretty'};
}
sub assets_output {
    my $self = shift;
    return defined $self->{'assets_output'};
}
sub set_base_directory {
    my $self = shift;
    my $base = shift;
    
    # ensure trailing slash
    $base =~ s{/?$}{/};
    
    $self->{'base_directory'} = $base;
}
sub get_base_directory {
    my $self = shift;
    
    return $self->{'base_directory'};
}
sub set_base_url {
    my $self = shift;
    
    $self->{'base_url'} = shift;
}
sub get_base_url {
    my $self = shift;
    
    return $self->{'base_url'};
}
sub get_http_timeout {
    my $self = shift;
    return $self->{'http_timeout'};
}
sub set_http_timeout {
    my $self = shift;
    
    $self->{'http_timeout'} = shift;
}
sub has_http {
    my $self = shift;
    
    return defined $self->{'http_provider'};
}
sub get_http_provider {
    my $self = shift;
    
    return $self->{'http_provider'};
}
sub has_plugins {
    my $self = shift;
    return $self->{'has_plugins'};
}

my $elements_first = sub {
        my $a_element  = ( $a =~ m{^[a-z]}i );
        my $b_element  = ( $b =~ m{^[a-z]}i );
        my $element_count = $a_element + $b_element;

        return ( $a_element ? -1 : 1 )
            if 1 == $element_count;
        return $a cmp $b;
    };

sub parse_file {
    my $self     = shift;
    my $file     = shift;
    my $location = shift;
    
    my $string = $self->read_file( $file );
    return $self->parse( $string, $file, $location )
        if defined $string;
    
    return;
}
sub parse_file_structure {
    my $self = shift;
    my $file = shift;
    
    my $base = $self->get_base_directory();
    return undef
        unless defined $base && -d $base;
    
    my $stylesheet = basename( $file );
    my $directory  = dirname( $file );
    my @blocks;
    my $path;
    
    foreach my $section ( split m{/}, $directory ) {
           $path  .= "${section}/";
        my $target = "${base}${path}${stylesheet}";
        
        my @file_blocks = $self->parse_file( $target );
        push @blocks, @file_blocks
            if @file_blocks;    # non-existent file is not an error
    }
    
    return @blocks;
}
sub parse_url {
    my $self     = shift;
    my $url      = shift;
    my $location = shift;
    
    my $string = $self->read_url( $url );
    return $self->parse( $string, $url, $location )
        if defined $string;
    
    return;
}
sub parse_url_structure {
    my $self = shift;
    my $file = shift;
    
    my $base = $self->get_base_url();
    return undef
        unless defined $base && $base =~ m{https?://};
    
    my $stylesheet = basename( $file );
    my $directory  = dirname( $file );
    my @blocks;
    my $path;
    
    foreach my $section ( split m{/}, $directory ) {
           $path  .= "${section}/";
        my $target = "${base}${path}${stylesheet}";
        
        my @file_blocks = $self->parse_url( $target );
        push @blocks, @file_blocks
            if @file_blocks;    # non-existent url is not an error
    }
    
    return @blocks;
}
sub parse_string {
    my $self     = shift;
    my $string   = shift;
    my $location = shift;
    
    return $self->parse( $string )
}
sub parse_stylesheet {
    my $self       = shift;
    my $stylesheet = shift;
    my $location   = shift;
    
    my $target = $self->canonicalise_location( $stylesheet, $location );
    
    return $self->parse_url( $target, $location )
        if $target =~ RE_IS_URL;
    return $self->parse_file( $target, $location );
}
sub canonicalise_location {
    my $self     = shift;
    my $file     = shift;
    my $location = shift;
    
    my $target;
    
    # don't interfere with an absolute URL
    if ( $file =~ RE_IS_URL ) {
        $target = $file;
    }
    else {
        if ( $file =~ m{^/} ) {
            my $base = $self->get_base_directory();
            
            if ( defined $base ) {
                $target = "$base/$file";
            }
            else {
                $target = $file;
            }
            
            if ( defined $location ) {
                if ( $location =~ RE_MATCH_HOSTNAME ) {
                    $target = "${1}${file}";
                }
            }
        }
        else {
            if ( defined $location ) {
                $location =~ RE_MATCH_DIRECTORY;
                $target = "${1}/${file}";
            }
            else {
                my $base = $self->get_base_directory() || '';
                $target = "${base}${file}";
            }
        }
    }
    
    return $target;
}
sub output_as_string {
    my $self = shift;
    my @data = @_;
    
    my $output = '';
    foreach my $block ( @data ) {
        my $type = $block->{'type'} // '';
        
        if ( 'at-media' eq $type || 'import' eq $type ) {
            my $query  = $block->{'query'};
            my $string = $self->output_as_string( @{$block->{'blocks'}} );
            
            if ( defined $query && $query ) {
                $string =~ s{^}{ }gm;
                $output .= "\@media ${query}{\n${string}}\n";
            }
            else {
                $output .= $string;
            }
        }
        elsif ( 'verbatim' eq $type ) {
            $output .= $block->{'string'};
        }
        elsif ( 'boundary' eq $type ) {
            # just skip the block
        }
        else {
            $output .= $self->output_block_as_string( $block );
        }
    }
    
    return $output;
}
sub output_block_as_string {
    my $self  = shift;
    my $block = shift;
    
    my $shorthands_first_hacks_last = sub {
            # sort hacks after normal properties
            my $a_hack     = ( $a =~ m{^ \s* [_\*] }x );
            my $b_hack     = ( $b =~ m{^ \s* [_\*] }x );
            my $hack_count = $a_hack + $b_hack;
            return $a_hack ? 1 : -1
                if 1 == $hack_count;
            
            # sort properties with vendor prefixes before
            # their matching properties
            $a =~ m{^ \s* ( [-] \w+ - )? ( .* ) $}sx;
            my $a_vendor = defined $1
                           && ! defined first
                                    { $_ eq $1 } NOT_VENDOR_PREFIX;
            $b =~ m{^ \s* ( [-] \w+ - )? ( .* ) $}sx;
            my $b_vendor = defined $1
                           && ! defined first
                                    { $_ eq $1 } NOT_VENDOR_PREFIX;
            my $vendors = ( $a_vendor ) + ( $b_vendor );
            return $a_vendor ? -1 : 1
                if 1 == $vendors;

            # sort more-specific properties after less-specific properties
            $a =~ m{^ \s* ( [^:]+ ) : }x;
            my $a_declaration = $1;
            $b =~ m{^ \s* ( [^:]+ ) : }x;
            my $b_declaration = $1;
            my $a_specifics = ( $a_declaration =~ tr{-}{-} );
            my $b_specifics = ( $b_declaration =~ tr{-}{-} );
            return $a_specifics <=> $b_specifics
                if $a_specifics != $b_specifics;
            
            # just sort alphabetically
            return $a cmp $b;
        };
    
    my %properties = $self->output_properties( $block->{'block'} );
    return '' unless %properties;
    
    # unique selectors only
    my %seen;
    my @selectors = grep { !$seen{$_}++ } @{$block->{'selectors'}};
    
    my $output;
    my $separator = $self->pretty_output ? ",\n" : ',';
    
    my $selector   = join $separator, sort $elements_first @selectors;
    my $properties = join '', sort $shorthands_first_hacks_last
                                   keys %properties;
    
    return $self->pretty_output
                ? "${selector} \{\n${properties}\}\n"
                : "${selector}\{${properties}\}\n";
}
sub output_properties {
    my $self  = shift;
    my $block = shift;
    
    # separate out the important rules from the normal, so that they are
    # not accidentally shorthanded, despite being different values
    my %normal;
    my %important;
    foreach my $key ( keys %{$block} ) {
        if ( $key =~ m{^important-(.*)$} ) {
            $important{ $1 } = $block->{ $key };
        }
        else {
            $normal{ $key } = $block->{ $key };
        }
    }
    
    my %properties;
    my @outputters;
    
    if ( $self->has_plugins() ) {
        map { push @outputters, "${_}::output" }
            $self->plugins();
    }
    map { push @outputters, "CSS::Prepare::Property::${_}::output" }
        @MODULES;
    
    foreach my $outputter ( @outputters ) {
        my( @normal, @important );
        
        eval {
            no strict 'refs';
            @normal    = &$outputter( $self, \%normal );
            @important = &$outputter( $self, \%important );
        };
        say STDERR $@ if $@;
        
        foreach my $property ( @normal ) {
            $properties{ $property } = 1
                if defined $property;
        }
        foreach my $property ( @important ) {
            if ( defined $property ) {
                my $prefix = $self->output_separator;
                $property =~ s{;$}{${prefix}!important;};
                $properties{ $property } = 1;
            }
        }
    }
    
    return %properties;
}
sub output_format {
    my $self = shift;
    
    return $self->pretty_output
               ? $pretty_format
               : $concise_format;
}
sub output_separator {
    my $self = shift;
    
    return $self->pretty_output
               ? $pretty_separator
               : $concise_separator;
}

sub fetch_file {
    my $self     = shift;
    my $file     = shift;
    my $location = shift;
    
    my $target = $self->canonicalise_location( $file, $location );
    
    return $self->read_url( $target )
        if $target =~ RE_IS_URL;
    return $self->read_file( $target );
}
sub read_file {
    my $self = shift;
    my $file = shift;
    
    my $handle = FileHandle->new( $file );
    if ( defined $handle ) {
        local $/;
        
        return <$handle>;
    }
    
    return;
}
sub read_url {
    my $self = shift;
    my $url  = shift;
    
    my $provider = $self->get_http_provider();
    given ( $provider ) {
        when ( 'lite' ) { return $self->get_url_lite( $url ); }
        when ( 'lwp'  ) { return $self->get_url_lwp( $url ); }
    }
    
    return;
}
sub get_url_lite {
    my $self  = shift;
    my $url   = shift;
    my $depth = shift // 1;
    
    # don't follow infinite redirections
    return unless $depth <= MAX_REDIRECT;
    
    my $http = HTTP::Lite->new();
       $http->{'timeout'} = $self->get_http_timeout;
    
    my $code = $http->request( $url );
    
    given ( $code ) {
        when ( 200 ) { return $http->body(); }
        when ( 301 || 302 || 303 || 307 ) {
            my $location = $http->get_header( 'Location' );
            return $self->get_url_lite( $location, $depth+1 );
        }
        default      { return; }
    }
}
sub get_url_lwp {
    my $self = shift;
    my $url  = shift;
    
    my $http = LWP::UserAgent->new( max_redirect => MAX_REDIRECT );
       $http->timeout( $self->get_http_timeout );
    
    my $resp = $http->get( $url );
    my $code = $resp->code();
    
    given ( $code ) {
        when ( 200 ) { return $resp->decoded_content(); }
        default      { return; }
    }
}
sub copy_file_to_staging {
    my $self     = shift;
    my $file     = shift;
    my $location = shift;
    
    return unless $self->assets_output;
    my $content  = $self->fetch_file( $file, $location );
    return unless $content;
    
    my $hex         = sha1_hex $content;
    my $filename    = basename $file;
    my $assets_file = sprintf "%s/%s/%s-%s",
                          $self->{'assets_base'},
                          substr( $hex, 0, 3 ),
                          substr( $hex, 4 ),
                          $filename;
    my $output_file = sprintf "%s/%s/%s-%s",
                          $self->{'assets_output'},
                          substr( $hex, 0, 3 ),
                          substr( $hex, 4 ),
                          $filename;
    my $output_dir  = dirname $output_file;
    
    mkpath $output_dir;
    my $handle = FileHandle->new( $output_file, 'w' );
    print {$handle} $content;
    
    return $assets_file;
}

sub parse {
    my $self     = shift;
    my $string   = shift;
    my $location = shift;
    
    return unless defined $string;
    
    my( $charset, $stripped ) = strip_charset( $string );
    return { errors => [{ fatal => "Unsupported charset '${charset}'" }] }
        unless 'UTF-8' eq $charset;
    
    $stripped = $self->strip_comments( $stripped );
    $string   = escape_braces_in_strings( $stripped );
    
    my @split = $self->split_into_statements( $string, $location );
    
    my @statements;
    my @appended;
    foreach my $statement ( @split ) {
        my $type = $statement->{'type'};
        
        if ( 'appended' eq $type ) {
            push @statements, @{$statement->{'content'}};
        }
        elsif ( 'import' eq $type ) {
            push @statements, $statement;
        }
        elsif ( 'rulesets' eq $type ) {
            my ( $rule_sets, $appended ) = $self->parse_rule_sets(
                    $statement->{'content'}, $location
                );
            
            push @statements, @$rule_sets;
            push @split, {
                    type => 'appended',
                    content => $appended,
                }
                if defined $appended;
        }
        elsif ( 'at-media' eq $type ) {
            my ( $rule_sets, $appended ) = $self->parse_rule_sets(
                    $statement->{'content'}, $location
                );
            
            push @{$statement->{'blocks'}}, @$rule_sets;
            delete $statement->{'content'};
            push @statements, $statement;
            push @split, {
                    type => 'appended',
                    content => $appended,
                }
                if defined $appended;
        }
        else {
            die "unknown type '${type}'";
        }
    }
    
    return @statements;
}
sub parse_rule_sets {
    my $self     = shift;
    my $styles   = shift;
    my $location = shift;
    
    return []
        unless defined $styles;
    
    my @declaration_blocks
        = split_into_declaration_blocks( $styles );
    
    my @rule_sets;
    my @appended;
    foreach my $block ( @declaration_blocks ) {
        my $type           = $block->{'type'} // '';
        my $preserve_as_is = defined $block->{'errors'}
                             || 'verbatim' eq $type
                             || 'boundary' eq $type;
        
        if ( $preserve_as_is ) {
            push @rule_sets, $block;
        }
        else {
            # extract from the string a data structure of selectors
            my( $selectors, $selectors_errors )
                = parse_selectors( $block->{'selector'} );
            
            my $declarations       = {};
            my $declaration_errors = [];
            my $append_blocks;
            
            # CSS2.1 4.1.6: "the whole statement should be ignored if
            # there is an error anywhere in the selector"
            if ( ! @$selectors_errors ) {
                # extract from the string a data structure of
                # declarations and their properties
                ( $declarations, $declaration_errors, $append_blocks )
                    = $self->parse_declaration_block(
                          $block->{'block'}, $location, $selectors
                      );
            }
            
            push @appended, @$append_blocks
                if defined @$append_blocks;
            
            my $is_empty = !@$selectors_errors
                           && !@$declaration_errors
                           && !%{$declarations};
            
            push @rule_sets, {
                    original  => unescape_braces( $block->{'block'} ),
                    selectors => $selectors,
                    errors    => [
                        @$selectors_errors,
                        @$declaration_errors
                    ],
                    block     => $declarations,
                }
                unless $is_empty;
        }
    }
    
    return \@rule_sets, \@appended;
}
sub strip_charset {
    my $string = shift;
    
    # "User agents must support at least the UTF-8 encoding."
    my $charset = "UTF-8";
    
    # "Authors using an @charset rule must place the rule at the very beginning 
    #  of the style sheet, preceded by no characters"
    if ( $string =~ s{^ \@charset \s " ([^"]+) "; }{}sx ) {
        $charset = $1;
    }
    
    return ( $charset, $string );
}
sub strip_comments {
    my $self   = shift;
    my $string = shift;
    
    # remove CDO/CDC markers
    $string =~ s{ <!-- }{}gsx;
    $string =~ s{ --> }{}gsx;
    
    if ( $self->support_extended_syntax ) {
        # remove line-level comments
        $string =~ s{ (?: ^ | \s ) // [^\n]* $ }{}gmx;
    }
    
    # disguise verbatim comments
    $string =~ s{
            \/ \* \! ( .*? ) \* \/
        }{%-COMMENT-%$1%-ENDCOMMENT-%}gsx;
    
    # disguise boundary markers
    $string =~ s{
            \/ \* ( \s+ \-\-+ \s+ ) \* \/
        }{%-COMMENT-%$1%-ENDCOMMENT-%}gsx;
    
    # remove CSS comments
    $string =~ s{ \/ \* .*? \* \/ }{}gsx;
    
    # reveal verbatim comments and boundary markers
    $string =~ s{%-COMMENT-%}{/*}gsx;
    $string =~ s{%-ENDCOMMENT-%}{*/}gsx;
    
    return $string;
}
sub escape_braces_in_strings {
    my $string = shift;
    
    my $strip_next_string = qr{
            ^
            ( .*?  )        # $1: everything before the string
            ( ['"] )        # $2: the string delimiter
            ( .*?  )        # $3: the content of the string
            (?<! \\ ) \2    # the string delimiter (but not escaped ones)
        }sx;
    
    # find all strings, and tokenise the braces within
    my $return;
    while ( $string =~ s{$strip_next_string}{}sx ) {
        my $before  = $1;
        my $delim   = $2;
        my $content = $3;
        
        $content =~ s{ \{ }{\%-LEFTBRACE-\%}gsx;
        $content =~ s{ \} }{\%-RIGHTBRACE-\%}gsx;
        $return .= "${before}${delim}${content}${delim}";
    }
    $return .= $string;
    
    return $return;
}
sub unescape_braces {
    my $string = shift;
    
    $string =~ s{\%-LEFTBRACE-\%}{\{}gs;
    $string =~ s{\%-RIGHTBRACE-\%}{\}}gs;
    
    return $string;
}
sub split_into_statements {
    my $self     = shift;
    my $string   = shift;
    my $location = shift;
    
    # "In CSS 2.1, any @import rules must precede all other rules (except the
    #  @charset rule, if present)." (CSS 2.1 #6.3)
    my ( $remainder, @statements )
        = $self->do_import_rules( $string, $location );
    
    my $splitter = qr{
            ^
            ( .*? )                 # $1: everything before the media block
            \@media \s+ (           # $2: the media query
                $grammar_media_query_list
            ) \s*
            (                       # $3: (used in the nested expression)
                \{ (?:              # the content of the media block,
                    (?> [^\{\}]+ )  # which is a nested recursive match...
                    |               # 
                    (?3)            # ...triggered here ("(?3)" means use $3
                )* \}               # matching again)
            )
        }sx;
    
    while ( $remainder =~ s{$splitter}{}sx ) {
        my $before = $1;
        my $query  = $2;
        my $block  = $3;
        
        # strip the outer braces from the media block
        $block =~ s{^ \{ (.*) \} $}{$1}sx;
        
        push @statements, {
                type => 'rulesets',
                content => $before,
            };
        push @statements, {
                type => 'at-media',
                query => $query,
                content => $block,
            };
    }
    
    push @statements, {
            type => 'rulesets',
            content => $remainder,
        };
    
    return @statements;
}
sub do_import_rules {
    my $self      = shift;
    my $string    = shift;
    my $directory = shift;
    
    # "In CSS 2.1, any @import rules must precede all other rules (except the
    #  @charset rule, if present)." (CSS 2.1 #6.3)
    my $splitter = qr{
            ^
            \s* \@import \s*
            (
                $string_value
                |
                $url_value
            )
            (?:
                \s+
                ( $media_types_value )
            )?
            \s* \;
        }x;
    
    my @blocks;
    while ( $string =~ s{$splitter}{}sx ) {
        my $import = $1;
        my $media  = $2;
        
        $import =~ s{^ url\( \s* (.*?) \) $}{$1}x;   # strip url()
        $import =~ s{^ ( ['"] ) (.*?) \1 $}{$2}x;    # strip quotes
        
        my @styles = $self->parse_stylesheet( $import, $directory );
        
        if ( @styles ) {
            push @blocks, {
                    type   => 'import',
                    query  => $media,
                    blocks => [ @styles ],
                };
        }
    }
    
    return $string, @blocks;
}
sub split_into_declaration_blocks {
    my $string = shift;
    my @blocks;
    
    my $get_import_rule = qr{
            ^
            \@import \s+
            (?: $string_value | $url_value )
            (?: \s+ ( $media_types_value ) )?
            \s* \; \s*
        }x;
    my $get_charset_rule = qr{
            ^
            \@charset \s \" [^"]+ \";
            \s*
        }x;
    my $get_block = qr{
            ^
            (?<selector> .*? ) \s*
            \{  (?<block> [^\}]* ) \} \s*
        }sx;
    my $get_comment = qr{
            ^
            ( \/ \* (.*?) \* \/ ) \s*
        }sx;
    my $get_verbatim = qr{
            ^
            \/ \* \s+ verbatim \s+ \*\/
            \s* ( .*? ) \s*
            \/ \* \s+ \-\-+ \s+ \*\/
        }sx;
    my $get_chunk_boundary = qr{
            ^
            \/ \* \s+ \-\-+ \s+ \* \/ \s*
        }sx;
        
    while ( $string ) {
        $string =~ s{^\s*}{}sx;
        
        # check for a rogue @import rule
        if ( $string =~ s{$get_import_rule}{}sx ) {
            push @blocks, {
                    errors => [
                        {
                            error => '@import rule after statement(s) -- '
                                     . 'ignored (CSS 2.1 #4.1.5)',
                        },
                    ],
                };
        }
        
        # check for a rogue @charset rule
        elsif ( $string =~ s{$get_charset_rule}{}sx ) {
            push @blocks, {
                    errors => [
                        {
                            error => '@charset rule inside stylsheet -- '
                                     . 'ignored (CSS 2.1 #4.4)',
                        },
                    ],
                };
        }
        
        # check for chunk boundaries
        elsif ( $string =~ s{$get_chunk_boundary}{}sx ) {
            push @blocks, {
                    type => 'boundary',
                };
        }
        
        # check for verbatim blocks
        elsif ( $string =~ s{$get_verbatim}{}sx ) {
            push @blocks, {
                    type => 'verbatim',
                    string => "$1\n",
                };
        }
        
        # check for verbatim comments
        elsif ( $string =~ s{$get_comment}{}sx ) {
            push @blocks, {
                    type => 'verbatim',
                    string => "$1\n",
                };
        }
        
        # try and find the next declaration
        elsif ( $string =~ s{$get_block}{}sx ) {
            my %match = %+;
            push @blocks, \%match;
        }
        
        # give up
        elsif ( $string ) {
            push @blocks, {
                    errors => [{
                        error => "Unknown content:\n${string}\n",
                    }],
                };
            $string = undef;
        }
    }
    
    return @blocks;
}
sub parse_selectors {
    my $string = shift;
    my @selectors;
    
    my $splitter = qr{
            ^
            \s*
            ( [^,]+ )
            \s*
            \,?
        }sx;
    
    while ( $string =~ s{$splitter}{}sx ) {
        my $selector = $1;
           $selector =~ s{\s+}{ }sg;
        
        # CSS2.1 4.1.6: "the whole statement should be ignored if
        # there is an error anywhere in the selector"
        if ( ! is_valid_selector( $selector ) ) {
            return [], [
                    {
                        error => 'ignored block - unknown selector'
                               . " '${selector}' (CSS 2.1 #4.1.7)",
                    }
                ];
        }
        else {
            push @selectors, $selector;
        }
    }
    
    return \@selectors, [];
}
sub parse_declaration_block {
    my $self      = shift;
    my $block     = shift;
    my $location  = shift;
    my $selectors = shift;
    
    # make '{' and '}' back into actual brackets again
    $block = unescape_braces( $block );
    
    my( $remainder, @declarations ) = get_declarations_from_block( $block );
    my( $declarations, $append_blocks )
        = $self->expand_declarations( \@declarations, $selectors );
    
    my %canonical;
    my @errors;
    
    DECLARATION:
    foreach my $declaration ( @$declarations ) {
        my %match = %{$declaration};
        
        my $star_hack       = 0;
        my $underscore_hack = 0;
        my $important       = 0;
        my $has_hack        = 0;
        
        if ( $self->support_hacks ) {
            $star_hack = 1
                if $match{'property'} =~ s{^\*}{};
            $underscore_hack = 1
                if $match{'property'} =~ s{^_}{};
            $has_hack = $star_hack || $underscore_hack;
        }
        
        $important = 1
            if $match{'value'} =~ s{ \! \s* important $}{}x;
        
        # strip possible extraneous whitespace
        $match{'value'} =~ s{ \s+ $}{}x;
        
        my( $parsed_as, $errors )
            = $self->parse_declaration( $has_hack, $location, %match );
        
        if ( defined $parsed_as or $errors ) {
            push @errors, @$errors
                if @$errors;
            
            my %parsed;
            foreach my $property ( keys %$parsed_as ) {
                my $value = $parsed_as->{ $property };
                $property = "_$property"
                    if $underscore_hack;
                $property = "*$property"
                    if $star_hack;
                $property = "important-$property"
                    if $important;
                
                $parsed{ $property } = $value;
            }
            
            if ( %parsed ) {
                %canonical = (
                        %canonical,
                        %parsed,
                    );
            }
        }
        else {
            push @errors, {
                    error => "invalid property: '$match{'property'}'"
                };
        }
    }
    if ( $remainder !~ m{^ \s* $}sx ) {
        $remainder =~ s{^ \s* (.*?) \s* $}{$1}sx;
        
        push @errors, {
                error => "invalid property: '$remainder'",
            };
    }
    
    return \%canonical, \@errors, \@$append_blocks;
}
sub get_declarations_from_block {
    my $block = shift;
    
    my $splitter = qr{
            ^
            \s*
            (?<property> [^:]+? )
            \s* \: \s*
            (?<value> [^;]+ )
            \;?
        }sx;
    
    my @declarations;
    while ( $block =~ s{$splitter}{}sx ) {
        my %match = %+;
        push @declarations, \%match;
    }
    
    return $block, @declarations;
}
sub parse_declaration {
    my $self        = shift;
    my $has_hack    = shift;
    my $location    = shift;
    my %declaration = @_;
    
    my @parsers;
    map { push @parsers, "CSS::Prepare::Property::${_}::parse" }
        @MODULES;
    if ( $self->has_plugins() ) {
        map { push @parsers, "${_}::parse" }
            $self->plugins();
    }
    
    PARSER:
    foreach my $module ( @parsers ) {
        my $parsed_as;
        my $errors;
        
        eval {
            no strict 'refs';
            
            ( $parsed_as, $errors )
                = &$module( $self, $has_hack, $location, %declaration );
        };
        say STDERR $@ if $@;
        
        next PARSER
            unless ( defined $parsed_as || defined $errors );
        
        return( $parsed_as, $errors )
            if %$parsed_as or @$errors;
    }
    
    return;
}
sub expand_declarations {
    my $self         = shift;
    my $declarations = shift;
    my $selectors    = shift;
    
    my @filtered;
    my @append;
    if ( $self->has_plugins ) {
        DECLARATION:
        foreach my $declaration ( @$declarations ) {
            my $property = $declaration->{'property'};
            my $value    = $declaration->{'value'};
            
            PLUGIN:
            foreach my $plugin ( $self->plugins() ) {
                no strict 'refs';
                
                my $try_with = "${plugin}::expand";
                my( $filtered, $new_rulesets, $new_chunks )
                    = &$try_with( $self, $property, $value, $selectors );
                
                push @filtered, @{$filtered}
                    if defined $filtered;
                push @$declarations, @$new_rulesets
                    if defined $new_rulesets;
                push @append, @$new_chunks
                    if defined $new_chunks;
                
                next DECLARATION
                    if defined $filtered;
            }
            
            # if we get here, no plugin has dealt with the property
            push @filtered, $declaration;
        }
    }
    else {
        @filtered = @$declarations;
    }
    
    return \@filtered, \@append;
}

sub optimise {
    my $self = shift;
    my @data = @_;
    
    my @blocks;
    my @complete;
    while ( my $block = shift @data ) {
        my $type  = $block->{'type'};
        my $query = $block->{'query'};
        
        if ( defined $type ) {
            # process any previously collected blocks
            my( $savings, @optimised ) = $self->optimise_blocks( @blocks );
            undef @blocks;
            push @complete, @optimised
                if @optimised;
            
            # process this block
            ( $savings, @optimised )
                = $self->optimise_blocks( @{$block->{'blocks'}} );
            
            my $output_as_block = 'at-media' eq $type
                                  || ( 'import' eq $type && defined $query );
            if ( $output_as_block ) {
                push @complete, {
                        type   => $type,
                        query  => $block->{'query'},
                        blocks => [ @optimised ],
                    };
            }
            elsif ( 'verbatim' eq $type ) {
                push @complete, $block;
            }
            elsif ( 'boundary' eq $type ) {
                # nothing extra to do
            }
            else {
                push @complete, @optimised
                    if @optimised;
            }
        }
        else {
            # collect block for later processing
            push @blocks, $block;
        }
    }
    
    # process any remaining collected blocks
    my( $savings, @optimised ) = $self->optimise_blocks( @blocks );
    push @complete, @optimised
        if @optimised;
    
    return @complete;
}
sub optimise_blocks {
    my $self   = shift;
    my @blocks = @_;
    
    return 0 unless @blocks;
    
    my %styles     = $self->sort_blocks_into_hash( @blocks );
    my @properties = $self->array_of_properties( %styles );
    # my $before     = output_as_string( @properties );
    
    my $declaration_count = scalar @properties;
    $self->status( "  Found ${declaration_count} declarations." );
    
    my ( $savings, %state ) = $self->get_optimal_state( @properties );
    
    my @optimised = $self->get_blocks_from_state( %state );
    # my $after     = output_as_string( @optimised );
    # my $savings   = length( $before ) - length( $after );
    # 
    # say STDERR "Saved $savings bytes.";
    # # TODO - calculate savings, even when suboptimal has been used
    # my $savings = 0;
    
    return( $savings, @optimised );
}
sub sort_blocks_into_hash {
    my $self = shift;
    my @data = @_;
    
    my %styles;
    foreach my $block ( @data ) {
        foreach my $property ( keys %{ $block->{'block'} } ) {
            my $value = $block->{'block'}{ $property };
            
            foreach my $selector ( @{ $block->{'selectors'} } ) {
                $styles{ $selector }{ $property } = $value;
            }
        }
    }
    
    return %styles;
}
sub array_of_properties {
    my $self   = shift;
    my %styles = @_;
    
    my @properties;
    foreach my $selector ( keys %styles ) {
        my %properties = $self->output_properties( $styles{ $selector } );
        
        foreach my $property ( keys %properties ) {
            push @properties, $selector, $property;
        }
    }
    
    return @properties;
}
sub get_suboptimal_state {
    my %by_property = @_;
    
    # combine all properties by their selector -- makes a "margin:0;" property 
    # with an "li" selector and a "padding:0;" property with an "li" selector
    # into an "li" selector with both "margin:0;" and "padding:0;" properties
    my %by_selector;
    foreach my $property ( keys %by_property ) {
        foreach my $selector ( keys %{$by_property{ $property }} ) {
            $by_selector{ $selector }{ $property } = 1;
        }
    }
    
    # combine selectors by shared properties -- makes a "div" and an "li"
    # which both have "margin:0;" and "padding:0;" properties into a
    # "margin:0;padding:0;" property with a "div" and "li" selector
    undef %by_property;
    foreach my $selector ( sort keys %by_selector ) {
        my $properties = join '', sort keys %{$by_selector{ $selector }};
        
        $by_property{ $properties }{ $selector } = 1;
    }
    
    return %by_property;
}
sub get_optimal_state {
    my $self       = shift;
    my @properties = @_;
    
    my %by_property   = get_selectors_by_property( @properties );
    my $found_savings = 1;
    my $total_savings = 0;
    
    # if only one thing has that property, the only thing it can be
    # successfully combined with is something with the same selector,
    # so don't even bother calculating possible savings on them, just
    # combine them at the end
    my( %multiples, %singles );
    foreach my $property ( keys %by_property ) {
        my $selectors = scalar keys %{$by_property{ $property }};
        
        if ( $selectors > 1 ) {
            $multiples{ $property } = $by_property{ $property };
        }
        else {
            $singles{ $property } = $by_property{ $property };
        }
    }
    
    my $do_suboptimal_pass = 0;
    if ( scalar keys %multiples ) {
        my $start_time        = time();
        my $time_out_after    = $start_time + $self->suboptimal_threshold;
        my $check_for_timeout = $self->suboptimal_threshold > 0;
        my $count             = 0;
        my %cache;
        
        MIX:
        while ( $found_savings ) {
            # adopt a faster strategy if there are too many properties
            # to deal with, or the code tends towards infinite
            # time taken to calculate the results
            my $timed_out = $check_for_timeout
                            && ( time() >= $time_out_after );
            
            if ( $timed_out ) {
                $do_suboptimal_pass = 1;
                $self->status( "\r  Time threshold reached -- switching "
                               . 'to suboptimal optimisation.' );
                last MIX;
            }
            
            ( $found_savings, %multiples )
                = mix_biggest_properties( \%cache, %multiples );
            
            $total_savings += $found_savings;
            $count++;
            $self->status( "  [$count] savings $total_savings", 'line' );
        }
    }
    
    %by_property = (
            %singles,
            %multiples
        );
    
    %by_property = get_suboptimal_state( %by_property )
        if $do_suboptimal_pass;
    
    return( $total_savings, %by_property);
}
sub get_selectors_by_property {
    my @properties = @_;
    
    my %by_property;
    while ( @properties ) {
        my $selector = shift @properties;
        my $property = shift @properties;
        
        $by_property{ $property }{ $selector } = 1;
    }
    
    return %by_property;
}
sub mix_biggest_properties {
    my $cache       = shift;
    my %by_property = @_;
    
    my $num_children = sub {
            my $a_children = scalar keys %{$by_property{ $a }};
            my $b_children = scalar keys %{$by_property{ $b }};
            return $b_children <=> $a_children;
        };
    my @sorted_properties = sort $num_children keys %by_property;
    
    foreach my $property ( @sorted_properties ) {
        my( $mix_with, $saving )
            = get_biggest_saving_if_mixed( $property, $cache, %by_property );
        
        if ( defined $mix_with ) {
            my %properties
                = mix_properties( $property, $mix_with, $cache, %by_property );
            return( $saving, %properties );
        }
    }
    
    return( 0, %by_property );
}
sub get_biggest_saving_if_mixed {
    my $property   = shift;
    my $cache      = shift;
    my %properties = @_;
    
    return if defined $cache->{'no_savings'}{ $property };
    
    my $unmixed_property_length
        = output_string_length( $property, keys %{$properties{ $property }} );
    my $largest_value = 0;
    my $largest;
    
    EXAMINE:
    foreach my $examine ( keys %properties ) {
        next if $property eq $examine;
        next if 1 == scalar( keys %{$properties{ $examine  }} );
        
        my( $a, $b ) = sort( $property, $examine );
        my $saving = $cache->{ $a }{ $b };
        
        if ( !defined $saving ) {
            my @common_selectors
                = get_common_selectors( $property, $examine, %properties );
            
            if ( 0 == scalar @common_selectors ) {
                $cache->{ $a }{ $b } = 0;
                next EXAMINE;
            }
            
            my @property_remaining
                = get_remaining_selectors( $examine, $property, %properties );
            my @examine_remaining
                = get_remaining_selectors( $property, $examine, %properties );
            
            my $unmixed_examine_length
                = output_string_length(
                      $examine, keys %{$properties{ $examine }} );
            my $mixed_common_length
                = output_string_length(
                      "${property},${examine}", @common_selectors );
            my $mixed_selector_length
                = output_string_length( $property, @property_remaining );
            my $mixed_examine_length
                = output_string_length( $examine, @examine_remaining );
            
            my $unmixed = $unmixed_property_length + $unmixed_examine_length;
            my $mixed   = $mixed_common_length
                          + $mixed_selector_length
                          + $mixed_examine_length;
            
            $saving = $unmixed - $mixed;
            $cache->{ $a }{ $b } = $saving;
        }
        
        if ( $saving > $largest_value ) {
            $largest_value = $saving;
            $largest       = $examine;
        }
    }
    
    $cache->{'no_savings'}{ $property } = 1
        unless $largest_value;
    
    return( $largest, $largest_value );
}
sub output_string_length {
    my $property  = shift;
    my @selectors = @_;
    
    return 0
        unless scalar @selectors;
    
    my $string = sprintf '%s{%s}',
            join( ',', @selectors ),
            $property;
    
    return length $string;
}
sub get_common_selectors {
    my $property   = shift;
    my $examine    = shift;
    my %properties = @_;
    
    my @common = grep {
            $_ if defined $properties{ $property }{ $_};
        } keys %{$properties{ $examine }};
    
    return @common;
}
sub get_remaining_selectors {
    my $property   = shift;
    my $examine    = shift;
    my %properties = @_;
    
    my @remaining = grep {
            $_ if !defined $properties{ $property }{ $_};
        } keys %{$properties{ $examine }};
    
    return @remaining;
}
sub mix_properties {
    my $property   = shift;
    my $mix_with   = shift;
    my $cache      = shift;
    my %properties = @_;
    
    my $mixed_property = join '', sort( $property, $mix_with );
    my @common_selectors
        = get_common_selectors( $property, $mix_with, %properties );
    
    delete $cache->{ $property };
    delete $cache->{'no_savings'}{ $property };
    delete $cache->{ $mix_with };
    delete $cache->{'no_savings'}{ $mix_with };
    
    foreach my $selector ( @common_selectors ) {
        $properties{ $mixed_property }{ $selector } = 1;
        delete $properties{ $property }{ $selector };
        delete $properties{ $mix_with }{ $selector };
    }
    
    delete $properties{ $property }
        unless scalar keys %{$properties{ $property }};
    delete $properties{ $mix_with }
        unless scalar keys %{$properties{ $mix_with }};
    
    return %properties;
}
sub get_blocks_from_state {
    my $self        = shift;
    my %by_property = @_;
    
    my $elements_first = sub {
            my $a_element  = ( $a =~ m{^[a-z]}i );
            my $b_element  = ( $b =~ m{^[a-z]}i );
            my $element_count = $a_element + $b_element;
            
            return ( $a_element ? -1 : 1 )
                if 1 == $element_count;
            return $a cmp $b;
        };
    
    my %by_selector;
    foreach my $property ( keys %by_property ) {
        my @selectors
            = sort $elements_first keys %{$by_property{ $property }};
        my $selector  = join ',', @selectors;
        
        $by_selector{ $selector }{ $property } = 1;
    }
    
    my @blocks;
    foreach my $selector ( sort $elements_first keys %by_selector ) {
        my @properties = sort keys %{$by_selector{ $selector }};
        my $properties = join '', @properties;
        my $css        = "${selector}{${properties}}";
        push @blocks, $self->parse_string( $css )
    }
    
    return @blocks;
}

sub is_valid_selector {
    my $test = shift;
    
    $test = lc $test;
    
    my $nmchar          = qr{ (?: [_a-z0-9-] ) }x;
    my $ident           = qr{ -? [_a-z] $nmchar * }x;
    my $element         = qr{ (?: $ident | \* ) }x;
    my $hash            = qr{ \# $nmchar + }x;
    my $class           = qr{ \. $ident }x;
    my $string          = qr{ (?: \' $ident \' | \" $ident \" ) }x;
    my $pseudo          = qr{
            \:
            (?:
                # TODO - I am deliberately ignoring FUNCTION here for now
                # FUNCTION \s* (?: $ident \s* )? \)
                $ident \( .* \)
                |
                $ident
            )
        }x;
    my $attrib          = qr{
            \[
                \s* $ident \s*
                (?:
                    (?: \= | \~\= | \|\= ) \s*
                    (?: $ident | $string ) \s*
                )?
                \s*
            \]
        }x;
    my $parts           = qr{ (?: $pseudo | $hash | $class | $attrib ) }x;
    my $simple_selector = qr{ (?: $element $parts * | $parts + ) }x;
    my $combinator      = qr{ (?: [\+\~] \s* | \> \s* ) }x;
    my $next_selector = qr{
            \s* (?: $combinator )? $simple_selector \s*
        }x;
    
    while ( $test =~ s{^ $next_selector }{}x ) {
        # do nothing, already validated by the regexp
    }
    
    return 0 if length $test;
    return 1;
}

sub status {
    my $self = shift;
    my $text = shift;
    my $temp = shift;
    
    no strict 'refs';
    
    my $status = $self->{'status'};
    &$status( $text, $temp );
}
sub status_to_stderr {
    my $text = shift;
    my $temp = shift;
    
    print STDERR ( $temp ? "\r" : '' ) . $text;
}

1;

__END__

=head1 NAME

B<CSS::Prepare> - pre-process cascading style sheets to make them ready for
deployment

=head1 SYNOPSIS

In your code:

    my $preparer = CSS::Prepare->new( %opts );
    foreach my $stylesheet ( @ARGV ) {
        print process_stylesheet( $stylesheet );
    }

In your build process:

    % cssprepare -e -o styles/*.css > styles/combined.css

=head1 OPTIONS

The B<new()> method accepts a hash as arguments to control aspects of the
eventual output.

=over

=item hacks I<(boolean)>

Switch support for various CSS "hacks" on or off. See L<Supported CSS hacks>
in L<CSS::Prepare::Manual>. Defaults to I<true>.

=item extended I<(boolean)>

Switch support for extensions to the CSS syntax, which are incompatible with
the CSS specification (but can make life easier). See L<Extending the CSS
syntax> in L<CSS::Prepare::Manual>. Defaults to I<false>.

=item suboptimal_threshold I<(int)>

Number of seconds that CSS::Prepare will spend optimising each CSS fragment in
the more accurate way before switching to a less accurate but much faster
algorithm. See <Optimising CSS> in L<CSS::Prepare::Manual>. Defaults to I<10>.

If set to zero, it will never switch to the suboptimal method. Do note that
large style sheets with thousands of rule sets can take several minutes to
process fully, and the extra savings are quite minimal after the first few
seconds have elapsed.

=item http_timeout I<(int)>

Number of seconds that CSS::Prepare will wait whilst trying to fetch a remote
style sheet before giving up. Defaults to I<30>.

=item pretty I<(boolean)>

Switch to support pretty-printed output rather than highly compressed.
Defaults to I<false>.

Note that this only affects the amount of white space used in the output. All
comments and invalid rule sets and declarations from the source style sheets
are still dropped before output.

=item status I<(callback)>

Override how status reports are handled. The callback subroutine is given two
parameters: the text to be printed and a flag to say if it is expected to be a
temporary line (ie. can be overwritten).

The default callback is:

    sub status_to_stderr {
        my $text = shift;
        my $temp = shift;
        
        print STDERR ( $temp ? "\r" : '' ) . $text;
    }

Status reports can be silenced by providing a null callback, like so:

    my $preparer = CSS::Prepare->new( status => sub {} );

=back

=head1 REQUIREMENTS

The only fixed requirement CSS::Prepare has is that the version of the perl
interpreter must be at least 5.10.

If you wish to use C<@import url(...);> in your style sheets you will need
one of L<HTTP::Lite> or L<LWP::UserAgent> installed.

Some parts of the extended CSS syntax are implemented as optional plugins.
For these to work you will need L<Module::Pluggable> installed.

To use the C<--server> option in the C<cssprepare> script, you will need
L<Plack::Runner> installed.

=head1 SEE ALSO

=over

=item *

L<cssprepare> (command-line script)

=item *

L<CSS::Prepare::Manual>

=item *

CSS::Prepare online: L<http://cssprepare.com/>

=back

=head1 AUTHOR

Mark Norman Francis, L<norm@cackhanded.net>.

=head1 COPYRIGHT AND LICENSE

Copyright 2010 Mark Norman Francis.

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

