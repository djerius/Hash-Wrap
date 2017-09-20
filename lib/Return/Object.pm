package Return::Object;

# ABSTRACT: on-the-fly generation of results objects

use strict;
use warnings;

our $VERSION = '0.01';

use Exporter::Shiny qw[ return_object ];

our @EXPORT = qw[ return_object ];


{
    package Return::Object::Class;
    use parent 'Return::Object::Base';
}

sub _generate_return_object {

    my ( $me ) = shift;
    my ( $name, $args, $global ) = @_;

    my ( @pre_code, @post_code );

    if ( $args->{-copy} ) {
        push @pre_code, '$hash = { %{ $hash } };';
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
            my $code
              = qq[ { package $class ; use parent 'Return::Object::Base'; } 1; ];
            eval( $code ) or do {
                require Carp;
                Carp::croak( "error generating on-the-fly class $class: $@" );
            };
        }
        elsif ( !$class->isa( 'Return::Object::Base' ) ) {
            require Carp;
            Carp::croak(
                qq[class ($class) is not a subclass of Return::Object::Base\n]
            );
        }
    }

    my $construct = 'my $obj = '
      . (
        $class->can( 'new' )
        ? qq[$class->new(\$hash);]
        : qq[bless \$hash, '$class';]
      );

    #<<< no tidy
    my $code =
      join( "\n",
            q[sub ($) {],
            q[my $hash = shift;],
            @pre_code,
            $construct,
            @post_code,
            q[return $obj;],
            q[}],
          );
    #>>>

    ## no critic (ProhibitStringyEval)
    return eval( $code ) || do {
        require Carp;
        Carp::croak( "error generating return_object subroutine: $@" );
    };
}


1;

# COPYRIGHT

__END__


=head1 SYNOPSIS


  use Return::Object;

  sub foo {
    return_object { a => 1 };
  }

  $result = foo();
  print $result->a;  # prints
  print $result->b;  # throws

=head1 DESCRIPTION


This module provides routines which encapsulate a hash as an object.
The object provides methods for keys in the hash; attempting to access
a non-existent key via a method will cause an exception.

The impetus for this was to encapsulate data returned from a
subroutine or method (hence the name).  Returning a bare hash can lead
to bugs if there are typos in hash key names when accessing the hash.

It is not necessary for the hash to be fully populated when the object
is created.  The underlying hash may be manipulated directly, and
changes will be reflected in the object's methods.  To prevent this,
consider using the lock routines in L<Hash::Util> on the object after
creation.

Only hash keys which are legal method names will be accessible via
object methods.

=head2 Object construction and constructor customization

By default C<Object::Return> exports a C<return_object> constructor
which, given a hashref, blesses it directly into the
B<Return::Object::Class> class.

The constructor may be customized to change which class the object is
instantiated from, and how it is constructed from the data.
C<Return::Object> uses L<Exporter::Tiny> to perform the customization.
For example,

  use Return::Object
    return_object => { -as => 'return_cloned_object',
                       -clone => 1 };

will create a version of C<return_object> which clones the passed hash
and is imported as C<return_cloned_object>.  To import it under
the original name, C<return_object>, leave out the C<-as> option.


The following options are available to customize the constructor.

=over

=item C<-as> => I<subroutine name>

This is optional, and imports the customized version of
C<return_object> with the given name.

=item C<-class> => I<class name>

The object will be blessed into the specified class.  If the class
should be created on the fly, specify the C<-create> option.
See L</Object Classes> for what is expected of the object classes.
This defaults to C<Object::Return::Class>.

=item C<-create> => I<boolean>

If true, and C<-class> is specified, a class with the given name
will be created.

=item C<-copy> => I<boolean>

If true, the object will store the data in a I<shallow> copy of the
hash. By default, the object uses the hash directly.

=item C<-clone> => I<boolean>

If true, the object will store the data in a deep copy of the hash,
made with L<Storeable/dclone>. By default, the object uses the hash
directly.


=back

=head2 Object Classes

An object class has the following properties:

=over

=item *

The class must be a subclass of C<Return::Object::Base>.

=item *

The class typically does not provide any methods, as they would mask
a hash key of the same name.

=item *

The class need not have a constructor.  If it does, it is passed a
hashref which it should bless as the actual object.  For example:

  package My::Result;
  use parent 'Return::Object::Base';

  sub new {
    my  ( $class, $hash ) = @_;
    return bless $hash, $class;
  }

This excludes having a hash key named C<new>.

=back

C<Return::Object::Base> provides an empty C<DESTROY> method, a
C<can> method, and an C<AUTOLOAD> method.  They will mask hash
keys with the same names.


=head1 SEE ALSO

Object::Result
Hash::AsObject
Data::AsObject
