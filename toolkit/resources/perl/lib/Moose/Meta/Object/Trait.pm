
package Moose::Meta::Object::Trait;
BEGIN {
  $Moose::Meta::Object::Trait::AUTHORITY = 'cpan:STEVAN';
}
BEGIN {
  $Moose::Meta::Object::Trait::VERSION = '2.0007';
}

use Scalar::Util qw(blessed);

sub _get_compatible_metaclass {
    my $orig = shift;
    my $self = shift;
    return $self->$orig(@_)
        || $self->_get_compatible_metaclass_by_role_reconciliation(@_);
}

sub _get_compatible_metaclass_by_role_reconciliation {
    my $self = shift;
    my ($other_name) = @_;
    my $meta_name = blessed($self) ? $self->_real_ref_name : $self;

    return unless Moose::Util::_classes_differ_by_roles_only(
        $meta_name, $other_name
    );

    return Moose::Util::_reconcile_roles_for_metaclass(
        $meta_name, $other_name
    );
}

1;

# ABSTRACT: Some overrides for L<Class::MOP::Object> functionality



=pod

=head1 NAME

Moose::Meta::Object::Trait - Some overrides for L<Class::MOP::Object> functionality

=head1 VERSION

version 2.0007

=head1 DESCRIPTION

This module is entirely private, you shouldn't ever need to interact with
it directly.

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

