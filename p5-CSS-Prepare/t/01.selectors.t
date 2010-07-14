use Modern::Perl;
use Test::More  tests => 84;

use CSS::Prepare;


my @valid_selectors = (
        'div', ' div ', '  div  ',
        'div div', ' div  div ', '  div    div  ',
        'div div div', ' div div div ',
        'div div div div', ' div div div div ',
        '*', ' * ', 
        '#div', ' #div ', ' #div #div ', ' #div #div #div ',
        '.div', ' .div ', ' .div .div ', ' .div .div .div ',
        'div#div', ' div#div ', ' div#div div#div ', 
            ' div#div div#div div#div ',
        'div.div', ' div.div ', ' div.div div.div ', 
            ' div.div div.div div.div ',
        ' a:link ', ' a:lang(en-GB) ', ' li:first-child ', 
            ' li:first-child:hover',
        ' div[class] ', ' div[class="blah"] ', ' div[class~="blah" ] ',
            ' .div[class] ', ' #div[class="blah"] ', 
            ' div.div[class~="blah" ] ', ' div#div[class] ', 
            ' div#div[class="blah"] ', ' div#div[class~="blah" ] ',
        ' div + div ', ' div + div + div ', ' div + #div + div ',
            ' div + .div + div ', ' div + div.div + div ',
        ' div > div ', ' div > div > div ', ' div > #div > div ',
            ' div > .div > div ', ' div > div.div > div ',
            'div>#div>div', 'div>.div>div', 'div>div.div>div',
        'DIV', '#DIV', '.DIV', 'DIV#DIV', 'DIV.DIV', 'div #DIV div',
        'DIV:link', 'DIV:first-child', 'DIV:first-child:hover',
        'DIV + DIV', 'DIV+DIV', 'DIV > DIV', 'DIV>DIV',
        'div ~ div', 'div~div',
    );
my @invalid_selectors = (
        'div!', ' div! ', '!div', ' !div ',
        'div@', ' div@ ', '@div', ' @div ',
        'div&', ' div& ', '&div', ' &div ',
        'div ! div', 'div @ div', 'div & div',
    );

foreach my $selector ( @valid_selectors ) {
    ok( CSS::Prepare::is_valid_selector( $selector ), 
        "valid {$selector}" );
}
foreach my $selector ( @invalid_selectors ) {
    ok( ! CSS::Prepare::is_valid_selector( $selector ), 
        "invalid {$selector}" );
}

