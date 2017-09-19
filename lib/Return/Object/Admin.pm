package Return::Object::Admin;

# ABSTRACT: Return::Object administration class

use Hash::Util qw[ lock_hash unlock_hash hashref_locked ];

use strict;
use warnings;

our $VERSION = '0.01';


sub new {

    my $class = shift;
    my $ref = shift;

    my $self = \$ref;
    weaken $self;

    return bless $self, $class;
}

sub object { ${$_[0]} }

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

sub add {

    my $self = shift;

    croak( "odd number of arguments\n" )
      if @_ % 2;

    if ( defined $self ) {

	my $object = $self->object;

        my $is_locked = hashref_locked( $object );

        unlock_hash( %{ $object } ) if $is_locked;
        while ( @_ ) {
            my ( $key, $value ) = ( shift, shift );
            $$self->{$key} = $value;
        }

        lock_hash( %{ $object } ) if $is_locked;
    }

    return $self;
}

1;
