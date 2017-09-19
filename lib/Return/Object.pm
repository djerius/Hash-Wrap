package Return::Object;

# ABSTRACT: on-the-fly generation of results objects

use strict;
use warnings;

our $VERSION = '0.01';

use Exporter::Shiny qw[ return_object ];

{ package Return::Object::Class;
  use parent 'Return::Object::Base';
}

sub _generate_return_object {

    my ( $me ) = shift;
    my ( $name, $args, $global ) = @_;

    my ( @pre_code, @post_code );

    if ( $args->{-copy} ) {
        push @pre_code, '$hash = { %{ $hash } };'
    }
    elsif ( $args->{-clone} ) {
        require Storable;
        push @pre_code, '$hash = Storable::dclone $hash;';
    }

    my $class = "${me}::Class";
    if ( defined $args->{-class} ) {

        $class = $args->{-class};

        if ( $args->{-create} ) {

            ## no critic (ProhibitStringyEval)
            my $code = qq[ { package $class ; use parent 'Return::Object::Base'; } 1; ];
            eval( $code )
              // do { require Carp;
                      Carp::croak( "error generating on-the-fly class $class: $@" );
                  };
        } elsif ( ! $class->isa( 'Return::Object::Base' ) ) {
            require Carp;
            Carp::croak( qq[class ($class) is not a subclass of Return::Object::Base\n] );
        }

    }

    my $code =  join( "\n",
                      q[sub {],
                      q[my $hash = shift;],
                      @pre_code,
                      qq[my \$obj = bless \$hash, '$class';],
                      @post_code,
                      q[return $obj;],
                      q[}]
                      );

    ## no critic (ProhibitStringyEval)
    return eval( $code ) // do { require Carp; Carp::croak( "error generating return_object subroutine: $@" ) };
}


1;

# COPYRIGHT

__END__


=head1 SYNOPSIS


  use Return::Object 'return_object';

  sub foo {

   ...

    return_object \%hash_result;

  }

=head1 DESCRIPTION

This module provides the L</return_object> subroutine, which
makes it easier to encapsulate values returned from a subroutine
as objects.

For hash results, the keys are available as methods, which ensures
that mistyped keys do not result in auto-vivified elements in the hash.

Result objects can also automatically be made immutable.


=head2 Object construction

By default C<Object::Return> generates a C<return_object> subroutine which
has the following characteristics:

=head3 For Hashes

=over

=item *

Hash elements may be added or deleted directly from the underlying hash

=item *

Hash keys are available as object methods.  Keys which do not have
valid method names are translated (see L</Key Translation>).

=back

=head3 For Arrays

=over

=item *

Hash elements may be added or deleted directly from the underlying hash

=item *

Hash keys are available as object methods.  Keys which do not have
valid method names are translated (see L</Key Translation>).



=back


=head3 Hashes

Hash return objects may have the



=head1 SEE ALSO

Object::Result
Hash::AsObject
Data::AsObject
