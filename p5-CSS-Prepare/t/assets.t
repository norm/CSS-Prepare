use Modern::Perl;
use Test::More;

use CSS::Prepare;
use Data::Dumper;
local $Data::Dumper::Terse     = 1;
local $Data::Dumper::Indent    = 1;
local $Data::Dumper::Useqq     = 1;
local $Data::Dumper::Deparse   = 1;
local $Data::Dumper::Quotekeys = 0;
local $Data::Dumper::Sortkeys  = 1;

plan tests => $ENV{'OFFLINE'} ? 7 : 10;

my $preparer = CSS::Prepare->new(
        assets_base   => 'http://assets.cssprepare.com',
        assets_output => 't/assets',
    );

# manually copy file
{
    $preparer->copy_file_to_staging( 't/static/img/placeholder.png' );
    ok( compare( 
            't/static/img/placeholder.png',
            't/assets/f43/8610a226fc1037f56418f57881350b20def2-placeholder.png',
        )
    );
}

# file copied as part of building CSS
{
    my @structure = $preparer->parse_stylesheet(
                        't/static/css/placeholder.css'
                    );
    is_deeply(
        \@structure,
        [
            {
                block => {
                    'background-image' => 'url(http://assets.cssprepare.com/d9e/06ce4890246cfb1236f8d7a4d7cbcc3c1659-placeholder20.png)',
                },
                errors => [],
                original => "\n    background-image:       url( ../img/placeholder20.png );\n",
                selectors => [ '.placeholder', ],
            },
        ],
    );
    ok( compare(
            't/static/img/placeholder20.png',
            't/assets/d9e/06ce4890246cfb1236f8d7a4d7cbcc3c1659-placeholder20.png',
        )
    );
    
    my $output = $preparer->output_as_string( @structure );
    my $expect = <<CSS;
.placeholder{background-image:url(http://assets.cssprepare.com/d9e/06ce4890246cfb1236f8d7a4d7cbcc3c1659-placeholder20.png);}
CSS
    ok( $output eq $expect );
}

# file copied from the internet as part of building CSS
if ( ! $ENV{'OFFLINE'} ) {
    my $preparer = CSS::Prepare->new(
            assets_base   => 'http://assets.cssprepare.com',
            assets_output => 't/assets',
        );
    my @structure = $preparer->parse_stylesheet(
            'http://tests.cssprepare.com/static/css/placeholder.css'
        );
    is_deeply(
        \@structure,
        [
            {
                block => {
                    'background-image' => 'url(http://assets.cssprepare.com/39e/57bf04de420095bc46ceccb5732e5d8a0a16-placeholder30.png)',
                },
                errors => [],
                original => "\n    background-image:       url( ../img/placeholder30.png );\n",
                selectors => [ '.placeholder', ],
            },
        ],
    );
    ok( compare(
            'http://tests.cssprepare.com/static/img/placeholder30.png',
            't/assets/39e/57bf04de420095bc46ceccb5732e5d8a0a16-placeholder30.png',
        )
    );
    
    my $output = $preparer->output_as_string( @structure );
    my $expect = <<CSS;
.placeholder{background-image:url(http://assets.cssprepare.com/39e/57bf04de420095bc46ceccb5732e5d8a0a16-placeholder30.png);}
CSS
    ok( $output eq $expect );
}

# file copied from alternate location as part of building CSS
{
    $preparer = CSS::Prepare->new(
            assets_base   => 'http://assets.cssprepare.com',
            assets_output => 't/assets',
            location      => 't/static/css/screen.css',
        );
    unlink 't/assetsd9e/06ce4890246cfb1236f8d7a4d7cbcc3c1659-placeholder20.png';
    
    my @structure = $preparer->parse_stylesheet(
                        't/static/css/screen/placeholder.css'
                    );
    is_deeply(
        \@structure,
        [
            {
                block => {
                    'background-image' => 'url(http://assets.cssprepare.com/d9e/06ce4890246cfb1236f8d7a4d7cbcc3c1659-placeholder20.png)',
                },
                errors => [],
                original => "\n    background-image:       url( ../img/placeholder20.png );\n",
                selectors => [ '.placeholder', ],
            },
        ],
    );
    ok( compare(
            't/static/img/placeholder20.png',
            't/assets/d9e/06ce4890246cfb1236f8d7a4d7cbcc3c1659-placeholder20.png',
        )
    );
    
    my $output = $preparer->output_as_string( @structure );
    my $expect = <<CSS;
.placeholder{background-image:url(http://assets.cssprepare.com/d9e/06ce4890246cfb1236f8d7a4d7cbcc3c1659-placeholder20.png);}
CSS
    ok( $output eq $expect );
}



sub compare {
    my $source = shift;
    my $target = shift;
    
    my $original = $preparer->fetch_file( $source );
    
    my $handle = FileHandle->new( $target );
    return unless defined $handle;
    
    my $new = do { local $/; <$handle> };
    
    return $original eq $new;
}
