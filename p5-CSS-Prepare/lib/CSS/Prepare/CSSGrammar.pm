package CSS::Prepare::CSSGrammar;

use Modern::Perl;
use Exporter;

our @ISA    = qw( Exporter );
our @EXPORT = qw(
        $grammar_media_query_list
    );



my $ident = qr{ -? [_a-z] [_a-z0-9-]* }ix;

# FIXME: this is lazy
my $term  = qr{ \S+ }x;

my $expression = qr{ \( \s* $ident \s* (?: : \s* $term )? \s* \) }x;

my $media_query = qr{
            (?:
                (?: only | not )? \s* $ident
                (?: \s* and \s* $expression )*
            )
        | 
            (?:
                $expression
                (?: and \s* $expression )*
            )
    }x;

our $grammar_media_query_list 
    = qr{ $media_query (?: \, \s* $media_query )* }x;
