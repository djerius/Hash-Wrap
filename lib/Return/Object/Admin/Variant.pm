package Return::Object::Admin::Variant;

use Package::Variant
  importing => [ 'overload', 'Role::Tiny' ];;


sub generate_overload {

    my ( $class ) = shift;

    sub {
	$class->new( @_ );
    }

};


sub make_variant {

    my ( $class, $target, %args ) = @_;

    my $admin = 'Return::Object::Admin';

    if ( defined $args{with} ) {
	my @with = 'ARRAY' eq ref $args->{with} ? @{ $args->{with} } : ();

	$admin = Role::Tiny->create_class_with_roles ('Return::Object::Admin', @with);
    }

    overload->import( '&{}' => generate_overload( $admin );
}
