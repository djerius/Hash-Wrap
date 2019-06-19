#! perl

use Test2::V0;

use Hash::Wrap ();

subtest 'attrs names' => sub {

    like(
        dies { Hash::Wrap->import( { -attrs => 3 } ) },
        qr/not a legal/,
        "illegal identifier",
    );

    ok(
        lives { Hash::Wrap->import( { -attrs => 'id' } ) },
        "scalar",
    ) or note $@;

    ok(
        lives { Hash::Wrap->import( { -attrs => [ 'id' ] } ) },
        "array",
    ) or note $@;
};


subtest 'good attrs' => sub {

    ok(
        lives { Hash::Wrap->import( { -as => 'hw_scalar', -lvalue => 1, -attrs => 'id' } ) },
        "array",
    ) or note $@;

    my $object = hw_scalar( {} );

    my $class = ref $object;

    no strict 'refs';
    ok( defined *{"$class\::id"}{CODE}, "found accessor" );

    # check lvalue if available
    if ( $] ge '5.016000' ) {
        ok(
           lives { $object->id = 2 },
           "lvalue works",
          ) or note $@;
    }
    else {
        $object->{id} = 2;
    }

    is( $object->id, 2, "attribute set" );

};


done_testing;

