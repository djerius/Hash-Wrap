package Hash::Wrap::Base::LValue;

use strict;
use warnings;

use 5.01600;

our $VERSION = '0.02';

use Hash::Wrap ();
use parent 'Hash::Wrap::Base';

our $generate_signature = sub { ': lvalue' };

our $AUTOLOAD;
sub AUTOLOAD : lvalue {
    goto &{ Hash::Wrap::_autoload( $AUTOLOAD, $_[0] ) };
}

1;
