use Modern::Perl;
use Test::More  tests => 41;

use CSS::Prepare::Property::Values;



ok( 'color'         eq get_value_type( '#800000' )                          );
ok( 'color'         eq get_value_type( '#FFFFFF' )                          );
ok( 'color'         eq get_value_type( '#ccc' )                             );
ok( 'color'         eq get_value_type( 'red' )                              );
ok( 'color'         eq get_value_type( 'lime' )                             );
ok( 'color'         eq get_value_type( 'rgb(255,0,0)' )                     );
ok( 'color'         eq get_value_type( 'rgb(123,45,251)' )                  );
ok( 'color'         eq get_value_type( 'rgb( 100%, 25%, 83% )' )            );
ok( 'color'         ne get_value_type( '#c' )                               );
ok( 'color'         ne get_value_type( '#cccc' )                            );
ok( 'color'         ne get_value_type( '#hbhbhb' )                          );

ok( 'length'        eq get_value_type( '12px' )                             );
ok( 'length'        eq get_value_type( '-0.5em' )                           );
ok( 'length'        eq get_value_type( '0ex' )                              );
ok( 'length'        eq get_value_type( '3in' )                              );
ok( 'length'        eq get_value_type( '10cm' )                             );
ok( 'length'        eq get_value_type( '25mm' )                             );
ok( 'length'        eq get_value_type( '58pc' )                             );
ok( 'length'        eq get_value_type( '16pt' )                             );

ok( 'percentage'    eq get_value_type( '87%' )                              );
ok( 'percentage'    eq get_value_type( '123.8%' )                           );

ok( 'url'           eq get_value_type( 'url("yellow")' )                    );
ok( 'url'           eq get_value_type( q{url('/static/shim.gif')} )         );
ok( 'url'           eq get_value_type( 'url(http://example.com/shim.gif)' ) );

ok( is_length_value( '0' )                                                  );                                  


ok( 'background-attachment' eq get_property_type( 'scroll' )                );
ok( 'background-attachment' eq get_property_type( 'fixed' )                 );

ok( 'background-repeat'     eq get_property_type( 'repeat' )                );
ok( 'background-repeat'     eq get_property_type( 'repeat-x' )              );
ok( 'background-repeat'     eq get_property_type( 'repeat-y' )              );
ok( 'background-repeat'     eq get_property_type( 'no-repeat' )             );

ok( 'border-style'          eq get_property_type( 'none' )                  );
ok( 'border-style'          eq get_property_type( 'hidden' )                );
ok( 'border-style'          eq get_property_type( 'dotted' )                );
ok( 'border-style'          eq get_property_type( 'dashed' )                );
ok( 'border-style'          eq get_property_type( 'solid' )                 );
ok( 'border-style'          eq get_property_type( 'double' )                );
ok( 'border-style'          eq get_property_type( 'groove' )                );
ok( 'border-style'          eq get_property_type( 'ridge' )                 );
ok( 'border-style'          eq get_property_type( 'inset' )                 );
ok( 'border-style'          eq get_property_type( 'outset' )                );


