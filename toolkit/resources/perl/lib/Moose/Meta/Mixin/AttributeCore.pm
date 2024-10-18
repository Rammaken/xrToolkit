package Moose::Meta::Mixin::AttributeCore;
BEGIN {
  $Moose::Meta::Mixin::AttributeCore::AUTHORITY = 'cpan:STEVAN';
}
BEGIN {
  $Moose::Meta::Mixin::AttributeCore::VERSION = '2.0007';
}

use strict;
use warnings;

use base 'Class::MOP::Mixin::AttributeCore';

__PACKAGE__->meta->add_attribute( 'isa'  => ( reader => '_isa_metadata' ) );
__PACKAGE__->meta->add_attribute( 'does' => ( reader => '_does_metadata' ) );
__PACKAGE__->meta->add_attribute( 'is'   => ( reader => '_is_metadata' ) );

__PACKAGE__->meta->add_attribute( 'required' => ( reader => 'is_required' ) );
__PACKAGE__->meta->add_attribute( 'lazy'     => ( reader => 'is_lazy' ) );
__PACKAGE__->meta->add_attribute(
    'lazy_build' => ( reader => 'is_lazy_build' ) );
__PACKAGE__->meta->add_attribute( 'coerce' => ( reader => 'should_coerce' ) );
__PACKAGE__->meta->add_attribute( 'weak_ref' => ( reader => 'is_weak_ref' ) );
__PACKAGE__->meta->add_attribute(
    'auto_deref' => ( reader => 'should_auto_deref' ) );
__PACKAGE__->meta->add_attribute(
    'type_constraint' => (
        reader    => 'type_constraint',
        predicate => 'has_type_constraint',
    )
);
__PACKAGE__->meta->add_attribute(
    'trigger' => (
        reader    => 'trigger',
        predicate => 'has_trigger',
    )
);
__PACKAGE__->meta->add_attribute(
    'handles' => (
        reader    => 'handles',
        writer    => '_set_handles',
        predicate => 'has_handles',
    )
);
__PACKAGE__->meta->add_attribute(
    'documentation' => (
        reader    => 'documentation',
        predicate => 'has_documentation',
    )
);

1;

# ABSTRACT: Core attributes shared by attribute metaclasses



=pod

=head1 NAME

Moose::Meta::Mixin::AttributeCore - Core attributes shared by attribute metaclasses

=head1 VERSION

version 2.0007

=head1 DESCRIPTION

This class implements the core attributes (aka properties) shared by all Moose
attributes. See the L<Moose::Meta::Attribute> documentation for API details.

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

