package Moose::Meta::Role::Application::ToInstance;
BEGIN {
  $Moose::Meta::Role::Application::ToInstance::AUTHORITY = 'cpan:STEVAN';
}
BEGIN {
  $Moose::Meta::Role::Application::ToInstance::VERSION = '2.0007';
}

use strict;
use warnings;
use metaclass;

use Scalar::Util 'blessed';

use base 'Moose::Meta::Role::Application';

__PACKAGE__->meta->add_attribute('rebless_params' => (
    reader  => 'rebless_params',
    default => sub { {} }
));

sub apply {
    my ( $self, $role, $object, $args ) = @_;

    my $obj_meta = Class::MOP::class_of($object) || 'Moose::Meta::Class';

    # This is a special case to handle the case where the object's metaclass
    # is a Class::MOP::Class, but _not_ a Moose::Meta::Class (for example,
    # when applying a role to a Moose::Meta::Attribute object).
    $obj_meta = 'Moose::Meta::Class'
        unless $obj_meta->isa('Moose::Meta::Class');

    my $cache = 1;
    undef $cache if grep { $_ ne '-alias' && $_ ne '-excludes' } keys %$args;

    my $class = $obj_meta->create_anon_class(
        superclasses => [ blessed($object) ],
        roles => [ $role, keys(%$args) ? ($args) : () ],
        cache => $cache,
    );

    $class->rebless_instance( $object, %{ $self->rebless_params } );
}

1;

# ABSTRACT: Compose a role into an instance



=pod

=head1 NAME

Moose::Meta::Role::Application::ToInstance - Compose a role into an instance

=head1 VERSION

version 2.0007

=head1 DESCRIPTION

=head2 METHODS

=over 4

=item B<new>

=item B<meta>

=item B<apply>

=item B<rebless_params>

=back

=head1 BUGS

See L<Moose/BUGS> for details on reporting bugs.

=head1 AUTHOR

Stevan Little <stevan@iinteractive.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Infinity Interactive, Inc..

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__


