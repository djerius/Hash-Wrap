package Hash::Wrap::Base;

# ABSTRACT: Hash::Wrap  base class

use 5.008009;

use strict;
use warnings;

our $VERSION = '0.03';

our $AUTOLOAD;

use Hash::Wrap ();
use Scalar::Util;

our $generate_signature = sub {
    return '';
};

our $generate_body = sub {

    my ( $self, $method, $key ) = @_;

    return qq{
        my \$self = shift;

        unless ( exists \$self->{'$key'} ) {
            require Carp;
            Carp::croak( qq[Can't locate object method "$key" via package \@{[ Scalar::Util::blessed( \$self ) ]} \n] );
          }

        \$self->{'$key'} = \$_[0] if \@_;

        return \$self->{'$key'};
   };
};


=begin pod_coverage

=head3 can

=end pod_coverage

=cut

sub can {

    my ( $self, $key ) = @_;

    my $class = Scalar::Util::blessed( $self );
    return if !defined $class;

    return unless exists $self->{$key};

    my $method = "${class}::$key";

    ## no critic (ProhibitNoStrict)
    no strict 'refs';
    return *{$method}{CODE} || Hash::Wrap::_generate_accessor( $self, $method, $key );
}

sub DESTROY { }

sub AUTOLOAD {

    goto &{ &Hash::Wrap::_autoload( $AUTOLOAD, $_[0] ) };
}

1;
