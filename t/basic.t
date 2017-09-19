#! perl

use Test2::V0;

use Return::Object 'return_object';
use Scalar::Util 'blessed';

use strict;
use warnings;

subtest 'basic' => sub {

    my $obj = return_object( {
        a => 1,
        b => 2
    } );

    ok( $obj->a, 1, 'retrieve value' );
    ok( $obj->b, 2, 'retrieve another value' );

    like( dies { $obj->c }, qr/locate object method/, 'unknown attribute' );

    $obj->{c} = 3;
    ok( $obj->c, 3, 'retrieve value added through hash' );

    delete $obj->{c};
    like( dies { $obj->c }, qr/locate object method/, 'retrieve deleted attribute' );

};


#{ package Return::Object::ClassA ; use parent 'Return::Object::Base'; };
use Return::Object  'return_object', { -as => 'return_A', -class => 'Return::Object::ClassA' };

# check that caching works
subtest 'cache' => sub {

    my $obj = return_A({ a => 1 } );

    my $class = blessed $obj;

    no strict 'refs';

    $DB::single=1;

    ok( !defined( *{ "${class}::a" }{CODE}), "no accessor for 'a'" );

    ok( $obj->a, 1, "retrieve 'a'" );

    my $accessor = *{ "${class}::a" }{CODE};

    is( $obj->can('a'), $accessor, "can() returns cached accessor" );


};

done_testing;
