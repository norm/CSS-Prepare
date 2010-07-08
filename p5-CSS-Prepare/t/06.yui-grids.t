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

if ( $ENV{'OFFLINE'} ) {
    plan skip_all => 'Not online.';
    exit;
}
plan tests => 2;

my $preparer = CSS::Prepare->new( status => sub{} );
my( @structure, $output, $css );

if ( ! $preparer->has_http() ) {
    ok( 1 == 0, 'HTTP::Lite or LWP::UserAgent not found' );
}


{
    $css = <<CSS;
body{text-align:center;}
#bd:after,#ft:after,#hd:after,.yui-g:after,.yui-gb:after,.yui-gc:after,.yui-gd:after,.yui-ge:after,.yui-gf:after{clear:both;content:".";display:block;height:0;visibility:hidden;}
#doc,.yui-t1,.yui-t2,.yui-t3,.yui-t4,.yui-t5,.yui-t6,.yui-t7{margin:auto;width:57.69em;text-align:left;*width:56.25em;}
#doc2{width:73.076em;*width:71.25em;}
#doc2,#doc4{margin:auto;text-align:left;}
#doc3{margin:auto 10px;text-align:left;*width:56.25em;}
#doc3,#yui-main .yui-b{width:auto;}
#doc4{width:74.923em;*width:73.05em;}
#yui-main .yui-b{float:none;position:static;}
#yui-main,.yui-g .yui-u .yui-g{width:100%;}
.yui-b{position:relative;_position:static;}
.yui-g .yui-g .yui-u{width:48.1%;*width:48.1%;*margin-left:0;}
.yui-g .yui-g,.yui-g .yui-gb,.yui-g .yui-gc,.yui-g .yui-gd,.yui-g .yui-ge,.yui-g .yui-gf,.yui-g .yui-u{float:right;width:49.1%;}
.yui-g .yui-gb .yui-u{_margin-left:1.0%;}
.yui-g .yui-gb .yui-u,.yui-gb .yui-g,.yui-gb .yui-gb,.yui-gb .yui-gc,.yui-gb .yui-gd,.yui-gb .yui-ge,.yui-gb .yui-gf,.yui-gb .yui-u,.yui-gc .yui-g{float:left;width:32%;margin-left:1.99%;}
.yui-g .yui-gb div.first,.yui-gb .yui-gb div.first{*width:32%;_width:31.7%;*margin-right:0;}
.yui-g .yui-gb div.first,.yui-gb div.first,.yui-gc div.first{margin-left:0;}
.yui-g .yui-gc .yui-u,.yui-gb .yui-gc .yui-u{margin-right:0;_float:right;_margin-left:0;}
.yui-g .yui-gc .yui-u,.yui-gc .yui-u{float:right;width:32%;}
.yui-g .yui-gc div.first,.yui-gc div.first,.yui-gd .yui-u{float:left;width:66%;}
.yui-g .yui-gd div.first{_width:29.9%;}
.yui-g .yui-ge div.first,.yui-g div.first,.yui-gb .yui-ge div.first,.yui-gb div.first,.yui-gc div.first div.first,.yui-ge div.first,.yui-gf div.first,.yui-t1 .yui-b,.yui-t2 .yui-b,.yui-t3 .yui-b{float:left;}
.yui-gb .yui-g .yui-u,.yui-gc .yui-g .yui-u,.yui-gd .yui-g .yui-u,.yui-ge .yui-g .yui-u,.yui-gf .yui-g .yui-u{width:49%;*width:48.1%;*margin-left:0;}
.yui-gb .yui-g div.first{*margin-right:4%;_margin-right:1.3%;}
.yui-gb .yui-g div.first,.yui-gb .yui-gb div.first{*margin-left:0;}
.yui-gb .yui-gb .yui-u{_margin-left:.7%;}
.yui-gb .yui-gb .yui-u,.yui-gb .yui-gc .yui-u{*margin-left:1.8%;}
.yui-gb .yui-gc .yui-u,.yui-ge div.first .yui-gd div.first{width:32%;}
.yui-gb .yui-gc div.first{width:66%;*float:left;*margin-left:0;*margin-right:0;}
.yui-gb .yui-gd .yui-u{*width:66%;_width:61.2%;}
.yui-gb .yui-gd div.first{width:32%;*width:31%;_width:29.5%;*margin-right:0;}
.yui-gb .yui-ge .yui-u{margin:0;*width:24%;_width:20%;}
.yui-gb .yui-ge div.first,.yui-gb .yui-gf .yui-u{*width:73.5%;_width:65.5%;}
.yui-gb .yui-ge div.yui-u,.yui-gb .yui-gf div.yui-u,.yui-gd .yui-g,.yui-t4 .yui-b,.yui-t5 .yui-b,.yui-t6 .yui-b{float:right;}
.yui-gb .yui-gf .yui-u{margin:0;}
.yui-gb .yui-gf div.first{float:left;*width:24%;_width:20%;}
.yui-gb .yui-u{*width:31.9%;*margin-left:1.9%;}
.yui-gc .yui-u,.yui-gd .yui-u{margin-left:1.99%;}
.yui-gd .yui-g{width:66%;}
.yui-gd div.first{float:left;width:32%;margin-left:0;}
.yui-ge .yui-g,.yui-ge .yui-u{float:right;width:24%;}
.yui-ge div.first{width:74.2%;}
.yui-ge div.first .yui-gd .yui-u{width:65%;}
.yui-gf .yui-g,.yui-gf .yui-u{float:right;width:74.2%;}
.yui-gf div.first{width:24%;}
.yui-t1 #yui-main .yui-b{margin-left:13.30769em;*margin-left:13.05em;}
.yui-t1 #yui-main,.yui-t2 #yui-main,.yui-t3 #yui-main{float:right;margin-left:-25em;}
.yui-t1 .yui-b{width:12.30769em;*width:12.00em;}
.yui-t2 #yui-main .yui-b{margin-left:14.8461em;*margin-left:14.55em;}
.yui-t2 .yui-b{width:13.8461em;}
.yui-t2 .yui-b,.yui-t4 .yui-b{*width:13.50em;}
.yui-t3 #yui-main .yui-b{margin-left:24.0769em;*margin-left:23.62em;}
.yui-t3 .yui-b,.yui-t6 .yui-b{width:23.0769em;*width:22.50em;}
.yui-t4 #yui-main .yui-b{margin-right:14.8456em;*margin-right:14.55em;}
.yui-t4 #yui-main,.yui-t5 #yui-main,.yui-t6 #yui-main{float:left;margin-right:-25em;}
.yui-t4 .yui-b{width:13.8456em;}
.yui-t5 #yui-main .yui-b{margin-right:19.4615em;*margin-right:19.125em;}
.yui-t5 .yui-b{width:18.4615em;*width:18.00em;}
.yui-t6 #yui-main .yui-b{margin-right:24.0769em;*margin-right:23.62em;}
.yui-t7 #yui-main .yui-b{display:block;margin:0 0 1em;}
CSS

    @structure = $preparer->parse_url(
                     'http://yui.yahooapis.com/2.8.0r4/build/grids/grids.css'
                 );
    
    my @errors = (
            { error => q(invalid property: 'zoom') },
        );
    my @found_errors;
    foreach my $block ( @structure ) {
        foreach my $error ( @{$block->{'errors'}} ) {
            push @found_errors, @{$block->{'errors'}};
        }
    }
    is_deeply( \@errors, \@found_errors )
        or say "YUI grids 2.8.0r4 errors was:\n" . Dumper \@errors;
    
    @structure = $preparer->optimise( @structure );
    $output    = $preparer->output_as_string( @structure );
    ok( $output eq $css )
        or say "YUI grids 2.8.0r4 was:\n" . $output;
}
