#! perl

use Test2::V0;

use Scalar::Util 'blessed';

use Hash::Wrap;

my %hash;

my $obj = wrap_hash( \%hash );

like( dies{ $obj->foo },
      qr{t/croak.t},
      "croak message has correct call frame",
);


done_testing;
