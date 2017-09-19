package Return::Object::Admin::Lock;

# ABSTRACT: Return::Object::Admin role with locks

use Role::Tiny;

use Hash::Util qw[ lock_hash unlock_hash hashref_locked ];

use strict;
use warnings;

our $VERSION = '0.01';


sub lock   {
    my $self = shift;

    lock_hash  ( %{ $self->object } )
      if defined $self;

    return $self;
}

sub unlock {
    my $self = shift;

    unlock_hash( %{ $self->object } )
      if defined $self;

    return $self;
}

1;
