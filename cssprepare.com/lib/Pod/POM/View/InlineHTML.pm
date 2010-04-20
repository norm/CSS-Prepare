package Pod::POM::View::InlineHTML;
use base qw( Pod::POM::View::HTML );

use Modern::Perl;

my @OVER;



sub new {
    my $class = shift;
    my %args  = @_;
    
    my $self  = $class->SUPER::new(@_)
                or return;
    
    $self->{'base_header_level'} = $args{'header_level'} 
                                   // 1;
    
    {
        no warnings;
        
        # must be an number
        $self->{'base_header_level'} = 0
            unless int( $self->{'base_header_level'} ) > 0;
    }
    
    # accept a hash of possible link targets
    $self->{'link_map'} = $args{'link_map'};
    
    return $self;
}


# not generating an HTML page, just a fragment, so no surrounding bumph
sub view_pod {
    my $self = shift;
    my $pod  = shift;
    
    return $pod->content->present( $self );
}

# allow the base header level to be set contextually in the constructor
# (so =head1 can actually be an H2, or H3 etc)
sub view_header {
    my $self   = shift;
    my $header = shift;
    my $level  = shift() + $self->{'base_header_level'};
    
    $level = 6 
        if $level > 6;
    $level = 1
        if $level < 1;
    
    my $title = $header->title->present( $self );
    my $id    = generate_id( $title );
    my $tag   = "h${level}";
    
    return "<${tag} id='${id}'>$title</${tag}>\n"
           . $header->content->present($self);
}
sub view_head1 {
    my $self = shift;
    return $self->view_header( shift, 0 );
}
sub view_head2 {
    my $self  = shift;
    return $self->view_header( shift, 1 );
}
sub view_head3 {
    my $self  = shift;
    return $self->view_header( shift, 2 );
}
sub view_head4 {
    my $self  = shift;
    return $self->view_header( shift, 3 );
}

# don't want anchors on list items
sub view_item {
    my $self = shift;
    my $item = shift;
    
    my $over    = ref $self ? $self->{ OVER } : \@OVER;
    my $strip   = $over->[-1];
    my $title   = $item->title();
    my $content = $item->content->present( $self );
    
    if ( defined $title ) {
        $title = $title->present($self) if ref $title;
        $title =~ s{$strip}{}i
            if $strip;
        
        $title = "<em class='intro'>${title}</em>\n"
            if length $title;
    }
    
    return "<li>${title}${content}</li>\n";
}

# add better html to the verbatim blocks
sub view_verbatim {
    my $self = shift;
    my $item = shift;
    
    $item =~ s{&}{&amp;}g;
    $item =~ s{<}{&lt;}g;
    $item =~ s{>}{&gt;}g;
    $item =~ s{^    (.*)$}{<span class="line">$1</span>}gm;
    
    return "<pre><code>$item</code></pre>";
}

# have some semantic meanings, not presentational ones
sub view_seq_bold {
    my $self = shift;
    my $text = shift;
    
    return "<strong>$text</strong>";
}
sub view_seq_italic {
    my $self = shift;
    my $text = shift;
    
    return "<em>$text</em>";
}
sub view_seq_link {
    my $self = shift;
    my $link = shift;
    
    # view_seq_text has already taken care of L<http://example.com/>
    if ($link =~ /^<a href=/ ) {
        return $link;
    }
    
    # full-blown URL's are emitted as-is
    if ($link =~ m{^\w+://}s ) {
        return make_href($link);
    }
    
    $link =~ s/\n/ /gs;   # undo line-wrapped tags
    
    # links to other CPAN modules
    if ( $link =~ m{::} ) {
        return "<i>$link</i>";
    }
    
    # already mapped links
    my $link_map = $self->{'link_map'};
    my $url      = $link_map->{ $link };
    return "<a href='${url}'>$link</a>"
        if defined $url;
    
    # *very* naive mailto: matching
    return "<a href='mailto:${link}'>$link</a>"
        if $link =~ m{^ \w+ \@ \w+ (?: \. \w+ )+ $}x;
}

sub generate_id {
    my $text = shift;
    
    $text =~ tr/A-Z/a-z/;           # lowercase IDs only
    $text =~ s{^\s*|\s*$}{}g;       # remove leading/trailing whitespace
    $text =~ s{'}{}g;               # remove apostrophes from words
    $text =~ s{\W+}{-}g;            # non-word characters get replaced
    
    return $text;
}

1;

#============================================================= -*-Perl-*-
#
# Pod::POM::View::HTML
#
# DESCRIPTION
#   HTML view of a Pod Object Model.
#
# AUTHOR
#   Andy Wardley   <abw@kfs.org>
#
# COPYRIGHT
#   Copyright (C) 2000 Andy Wardley.  All Rights Reserved.
#
#   This module is free software; you can redistribute it and/or
#   modify it under the same terms as Perl itself.
#
# REVISION
#   $Id: HTML.pm 33 2009-03-17 21:10:42Z ford $
#
#========================================================================
# 
# package Pod::POM::View::HTML;
# 
# require 5.004;
# 
# use strict;
# use Pod::POM::View;
# use base qw( Pod::POM::View );
# use vars qw( $VERSION $DEBUG $ERROR $AUTOLOAD );
# use Text::Wrap;
# 
# $VERSION = sprintf("%d.%02d", q$Revision: 1.6 $ =~ /(\d+)\.(\d+)/x);
# $DEBUG   = 0 unless defined $DEBUG;
# my $HTML_PROTECT = 0;
# 
# sub new {
#     my $class = shift;
#     my $self = $class->SUPER::new(@_)
#   || return;
# 
#     # initalise stack for maintaining info for nested lists
#     $self->{ OVER } = [];
# 
#     return $self;
# }
# 
# 
# sub view {
#     my ($self, $type, $item) = @_;
# 
#     if ($type =~ s/^seq_//) {
#   return $item;
#     }
#     elsif (UNIVERSAL::isa($item, 'HASH')) {
#   if (defined $item->{ content }) {
#       return $item->{ content }->present($self);
#   }
#   elsif (defined $item->{ text }) {
#       my $text = $item->{ text };
#       return ref $text ? $text->present($self) : $text;
#   }
#   else {
#       return '';
#   }
#     }
#     elsif (! ref $item) {
#   return $item;
#     }
#     else {
#   return '';
#     }
# }
# 
# 
# sub view_head1 {
#     my ($self, $head1) = @_;
#     my $title = $head1->title->present($self);
#     return "<h1>$title</h1>\n\n"
#   . $head1->content->present($self);
# }
# 
# 
# sub view_head2 {
#     my ($self, $head2) = @_;
#     my $title = $head2->title->present($self);
#     return "<h2>$title</h2>\n"
#   . $head2->content->present($self);
# }
# 
# 
# sub view_head3 {
#     my ($self, $head3) = @_;
#     my $title = $head3->title->present($self);
#     return "<h3>$title</h3>\n"
#   . $head3->content->present($self);
# }
# 
# 
# sub view_head4 {
#     my ($self, $head4) = @_;
#     my $title = $head4->title->present($self);
#     return "<h4>$title</h4>\n"
#   . $head4->content->present($self);
# }
# 
# 
# sub view_over {
#     my ($self, $over) = @_;
#     my ($start, $end, $strip);
#     my $items = $over->item();
# 
#     if (@$items) {
# 
#   my $first_title = $items->[0]->title();
# 
#   if ($first_title =~ /^\s*\*\s*/) {
#       # '=item *' => <ul>
#       $start = "<ul>\n";
#       $end   = "</ul>\n";
#       $strip = qr/^\s*\*\s*/;
#   }
#   elsif ($first_title =~ /^\s*\d+\.?\s*/) {
#       # '=item 1.' or '=item 1 ' => <ol>
#       $start = "<ol>\n";
#       $end   = "</ol>\n";
#       $strip = qr/^\s*\d+\.?\s*/;
#   }
#   else {
#       $start = "<ul>\n";
#       $end   = "</ul>\n";
#       $strip = '';
#   }
# 
#   my $overstack = ref $self ? $self->{ OVER } : \@OVER;
#   push(@$overstack, $strip);
#   my $content = $over->content->present($self);
#   pop(@$overstack);
#     
#   return $start
#       . $content
#       . $end;
#     }
#     else {
#   return "<blockquote>\n"
#       . $over->content->present($self)
#       . "</blockquote>\n";
#     }
# }
# 
# 
# sub view_item {
#     my ($self, $item) = @_;
# 
#     my $over  = ref $self ? $self->{ OVER } : \@OVER;
#     my $title = $item->title();
#     my $strip = $over->[-1];
# 
#     if (defined $title) {
#         $title = $title->present($self) if ref $title;
#         $title =~ s/$strip// if $strip;
#         if (length $title) {
#             my $anchor = $title;
#             $anchor =~ s/^\s*|\s*$//g; # strip leading and closing spaces
#             $anchor =~ s/\W/_/g;
#             $title = qq{<a name="item_$anchor"></a><b>$title</b>};
#         }
#     }
# 
#     return '<li>'
#         . "$title\n"
#         . $item->content->present($self)
#         . "</li>\n";
# }
# 
# 
# sub view_for {
#     my ($self, $for) = @_;
#     return '' unless $for->format() =~ /\bhtml\b/;
#     return $for->text()
#   . "\n\n";
# }
#     
# 
# sub view_begin {
#     my ($self, $begin) = @_;
#     return '' unless $begin->format() =~ /\bhtml\b/;
#     $HTML_PROTECT++;
#     my $output = $begin->content->present($self);
#     $HTML_PROTECT--;
#     return $output;
# }
#     
# 
# sub view_textblock {
#     my ($self, $text) = @_;
#     return $HTML_PROTECT ? "$text\n" : "<p>$text</p>\n";
# }
# 
# 
# sub view_verbatim {
#     my ($self, $text) = @_;
#     for ($text) {
#   s/&/&amp;/g;
#   s/</&lt;/g;
#   s/>/&gt;/g;
#     }
#     return "<pre>$text</pre>\n\n";
# }
# 
# 
# sub view_seq_bold {
#     my ($self, $text) = @_;
#     return "<b>$text</b>";
# }
# 
# 
# sub view_seq_italic {
#     my ($self, $text) = @_;
#     return "<i>$text</i>";
# }
# 
# 
# sub view_seq_code {
#     my ($self, $text) = @_;
#     return "<code>$text</code>";
# }
# 
# sub view_seq_file {
#     my ($self, $text) = @_;
#     return "<i>$text</i>";
# }
# 
# sub view_seq_space {
#     my ($self, $text) = @_;
#     $text =~ s/\s/&nbsp;/g;
#     return $text;
# }
# 
# 
# sub view_seq_entity {
#     my ($self, $entity) = @_;
#     return "&$entity;"
# }
# 
# 
# sub view_seq_index {
#     return '';
# }
# 
# 
# sub view_seq_link {
#     my ($self, $link) = @_;
# 
#     # view_seq_text has already taken care of L<http://example.com/>
#     if ($link =~ /^<a href=/ ) {
#         return $link;
#     }
# 
#     # full-blown URL's are emitted as-is
#     if ($link =~ m{^\w+://}s ) {
#         return make_href($link);
#     }
# 
#     $link =~ s/\n/ /g;   # undo line-wrapped tags
# 
#     my $orig_link = $link;
#     my $linktext;
#     # strip the sub-title and the following '|' char
#     if ( $link =~ s/^ ([^|]+) \| //x ) {
#         $linktext = $1;
#     }
# 
#     # make sure sections start with a /
#     $link =~ s|^"|/"|;
# 
#     my $page;
#     my $section;
#     if ($link =~ m|^ (.*?) / "? (.*?) "? $|x) { # [name]/"section"
#         ($page, $section) = ($1, $2);
#     }
#     elsif ($link =~ /\s/) {  # this must be a section with missing quotes
#         ($page, $section) = ('', $link);
#     }
#     else {
#         ($page, $section) = ($link, '');
#     }
# 
#     # warning; show some text.
#     $linktext = $orig_link unless defined $linktext;
# 
#     my $url = '';
#     if (defined $page && length $page) {
#         $url = $self->view_seq_link_transform_path($page);
#     }
# 
#     # append the #section if exists
#     $url .= "#$section" if defined $url and
#         defined $section and length $section;
# 
#     return make_href($url, $linktext);
# }
# 
# 
# # should be sub-classed if extra transformations are needed
# #
# # for example a sub-class may search for the given page and return a
# # relative path to it.
# #
# # META: where this functionality should be documented? This module
# # doesn't have docs section
# #
# sub view_seq_link_transform_path {
#     my($self, $page) = @_;
# 
#     # right now the default transform doesn't check whether the link
#     # is not dead (i.e. whether there is a corresponding file.
#     # therefore we don't link L<>'s other than L<http://>
#     # subclass to change the default (and of course add validation)
# 
#     # this is the minimal transformation that will be required if enabled
#     # $page = "$page.html";
#     # $page =~ s|::|/|g;
#     #print "page $page\n";
#     return undef;
# }
# 
# 
# sub make_href {
#     my($url, $title) = @_;
# 
#     if (!defined $url) {
#         return defined $title ? "<i>$title</i>"  : '';
#     }
# 
#     $title = $url unless defined $title;
#     #print "$url, $title\n";
#     return qq{<a href="$url">$title</a>};
# }
# 
# 
# 
# 
# # this code has been borrowed from Pod::Html
# my $urls = '(' . join ('|',
#      qw{
#        http
#        telnet
#        mailto
#        news
#        gopher
#        file
#        wais
#        ftp
#      } ) . ')';   
# my $ltrs = '\w';
# my $gunk = '/#~:.?+=&%@!\-';
# my $punc = '.:!?\-;';
# my $any  = "${ltrs}${gunk}${punc}";
# 
# sub view_seq_text {
#      my ($self, $text) = @_;
# 
#      unless ($HTML_PROTECT) {
#   for ($text) {
#       s/&/&amp;/g;
#       s/</&lt;/g;
#       s/>/&gt;/g;
#   }
#      }
# 
#      $text =~ s{
#         \b                           # start at word boundary
#          (                           # begin $1  {
#            $urls     :               # need resource and a colon
#     (?!:)                     # Ignore File::, among others.
#            [$any] +?                 # followed by one or more of any valid
#                                      #   character, but be conservative and
#                                      #   take only what you need to....
#          )                           # end   $1  }
#          (?=                         # look-ahead non-consumptive assertion
#                  [$punc]*            # either 0 or more punctuation followed
#                  (?:                 #   followed
#                      [^$any]         #   by a non-url char
#                      |               #   or
#                      $               #   end of the string
#                  )                   #
#              |                       # or else
#                  $                   #   then end of the string
#          )
#        }{<a href="$1">$1</a>}igox;
# 
#      return $text;
# }
# 
# 
# 1;
# 
# =head1 NAME
# 
# Pod::POM::View::HTML
# 
# =head1 DESCRIPTION
# 
# HTML view of a Pod Object Model.
# 
# =head1 METHODS
# 
# =over 4
# 
# =item C<view($self, $type, $item)>
# 
# =item C<view_pod($self, $pod)>
# 
# =item C<view_head1($self, $head1)>
# 
# =item C<view_head2($self, $head2)>
# 
# =item C<view_head3($self, $head3)>
# 
# =item C<view_head4($self, $head4)>
# 
# =item C<view_over($self, $over)>
# 
# =item C<view_item($self, $item)>
# 
# =item C<view_for($self, $for)>
# 
# =item C<view_begin($self, $begin)>
# 
# =item C<view_textblock($self, $textblock)>
# 
# =item C<view_verbatim($self, $verbatim)>
# 
# =item C<view_meta($self, $meta)>
# 
# =item C<view_seq_bold($self, $text)>
# 
# Returns the text of a C<BE<lt>E<gt>> sequence enclosed in a C<E<lt>b<E<gt>> element.
# 
# =item C<view_seq_italic($self, $text)>
# 
# Returns the text of a C<IE<lt>E<gt>> sequence enclosed in a C<E<lt>i<E<gt>> element.
# 
# =item C<view_seq_code($self, $text)>
# 
# Returns the text of a C<CE<lt>E<gt>> sequence enclosed in a C<E<lt>code<E<gt>> element.
# 
# =item C<view_seq_file($self, $text)>
# 
# =item C<view_seq_entity($self, $text)>
# 
# =item C<view_seq_index($self, $text)>
# 
# Returns an empty string.  Index sequences are suppressed in HTML view.
# 
# =item C<view_seq_link($self, $text)>
# 
# =back
# 
# =head1 AUTHOR
# 
# Andy Wardley E<lt>abw@kfs.orgE<gt>
# 
# =head1 COPYRIGHT AND LICENSE
# 
# Copyright (C) 2000 Andy Wardley.  All Rights Reserved.
# 
# This module is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
# 
# =cut
