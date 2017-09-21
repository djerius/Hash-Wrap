#! perl


use Test2::V0;

use Hash::Wrap ();


like(
    dies {
        Hash::Wrap->import( 'not_exported' )
    },
    qr/not_exported is not exported/,
    'not exported'
);

like(
    dies {
        Hash::Wrap->import( { -bad_option => 1 } )
    },
    qr/unknown option/,
    'bad option'
);

like(
    dies {
        Hash::Wrap->import( { -copy => 1, -clone => 1 } )
    },
    qr/cannot mix/,
    'copy + clone'
);

{
    package My::Import::Default;

    use Hash::Wrap;
}

ref_ok( *My::Import::Default::wrap_hash{CODE}, 'CODE', "default import" );

{
    package My::Import::As;

    use Hash::Wrap { -as => 'foo' };

}

ref_ok( *My::Import::As::foo{CODE}, 'CODE', "rename" );

{
    package My::Import::CloneNoRename;

    use Hash::Wrap { -clone => 1 };

}
ref_ok( *My::Import::CloneNoRename::wrap_hash{CODE}, 'CODE', "clone, no rename" );


done_testing;
