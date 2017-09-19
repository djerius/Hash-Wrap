package Return::Object::Class;

# ABSTRACT: Return::Object  base class

use strict;
use warnings;

our $VERSION = '0.01';

our $AUTOLOAD;

use Scalar::Util ();

use overload '&{}', sub {
    my $self = shift;

    ( my $pclass = Scalar::Util::blessed($self) ) =~ s/::[^:]*$//;

    my $admin = "${pclass}::Admin";

    require Module::Load;
    Module::Load::load $admin;
    $admin->new( @_ );
};

# this is called only if the method doesn't exist.
my $generate_accessor = sub {

    my ( $self, $method, $key ) = @_;

    no strict 'refs';
    *{$method} = sub {
        my $self = shift;

        unless ( exists $self->{$key} ) {
            require Carp;
            Carp::croak( qq[Can't locate object method "$key" via package @{[ Scalar::Util::blessed( $self ) ]} \n] );
          }

        $self->{$key} = $_[0] if @_;

        return $self->{$key};
      };

      return *{$method}{CODE};
};

sub can {

    my ( $self, $key ) = @_;

    my $class = Scalar::Util::blessed( $self );
    return if !defined $class;

    return undef unless exists $self->{$key};

    my $method = "${class}::$key";

    no strict 'refs';
    return *{$method}{CODE} // $self->$generate_accessor( $method, $key );
}

sub AUTOLOAD {

    my $self   = $_[0];
    my $method = $AUTOLOAD;

    ( my $key = $method ) =~ s/.*:://;

    unless ( Scalar::Util::blessed( $self ) ) {
        require Carp;
        Carp::croak( qq[Can't locate class method "$key" via package @{[ ref $self]} \n] )
    }

    unless ( exists $self->{$key} ) {
        require Carp;
        Carp::croak( qq[Can't locate object method "$key" via package @{[ ref $self]} \n] )
    }

#    my $sub = $self->$generate_accessor( $method, $key );

    goto &{ $self->$generate_accessor( $method, $key ) };
}


1;
