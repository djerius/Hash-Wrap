#! perl


use Test2::V0;

use Return::Object ();


like(
    dies {
        Return::Object->import( 'not_exported' )
    },
    qr/not_exported is not exported/,
    'not exported'
);

like(
    dies {
        Return::Object->import( { -bad_option => 1 } )
    },
    qr/unknown option/,
    'bad option'
);

like(
    dies {
        Return::Object->import( { -copy => 1, -clone => 1 } )
    },
    qr/cannot mix/,
    'copy + clone'
);

{
    package My::Import::Default;

    use Return::Object;
}

ref_ok( *My::Import::Default::return_object{CODE}, 'CODE', "default import" );

{
    package My::Import::As;

    use Return::Object { -as => 'foo' };

}

ref_ok( *My::Import::As::foo{CODE}, 'CODE', "rename" );

{
    package My::Import::CloneNoRename;

    use Return::Object { -clone => 1 };

}
ref_ok( *My::Import::CloneNoRename::return_object{CODE}, 'CODE', "clone, no rename" );


done_testing;
