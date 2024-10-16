
package Moose::Meta::TypeConstraint;
BEGIN {
  $Moose::Meta::TypeConstraint::AUTHORITY = 'cpan:STEVAN';
}
BEGIN {
  $Moose::Meta::TypeConstraint::VERSION = '2.0007';
}

use strict;
use warnings;
use metaclass;

use overload '0+'     => sub { refaddr(shift) }, # id an object
             '""'     => sub { shift->name },   # stringify to tc name
             bool     => sub { 1 },
             fallback => 1;

use Scalar::Util qw(blessed refaddr);
use Sub::Name qw(subname);
use Try::Tiny;

use base qw(Class::MOP::Object);

__PACKAGE__->meta->add_attribute('name'       => (reader => 'name'));
__PACKAGE__->meta->add_attribute('parent'     => (
    reader    => 'parent',
    predicate => 'has_parent',
));

my $null_constraint = sub { 1 };
__PACKAGE__->meta->add_attribute('constraint' => (
    reader  => 'constraint',
    writer  => '_set_constraint',
    default => sub { $null_constraint }
));
__PACKAGE__->meta->add_attribute('message'   => (
    accessor  => 'message',
    predicate => 'has_message'
));
__PACKAGE__->meta->add_attribute('coercion'   => (
    accessor  => 'coercion',
    predicate => 'has_coercion'
));

__PACKAGE__->meta->add_attribute('hand_optimized_type_constraint' => (
    init_arg  => 'optimized',
    accessor  => 'hand_optimized_type_constraint',
    predicate => 'has_hand_optimized_type_constraint',
));

sub parents {
    my $self;
    $self->parent;
}

# private accessors

__PACKAGE__->meta->add_attribute('compiled_type_constraint' => (
    accessor  => '_compiled_type_constraint',
    predicate => '_has_compiled_type_constraint'
));
__PACKAGE__->meta->add_attribute('package_defined_in' => (
    accessor => '_package_defined_in'
));

sub new {
    my $class = shift;
    my ($first, @rest) = @_;
    my %args = ref $first ? %$first : $first ? ($first, @rest) : ();
    $args{name} = $args{name} ? "$args{name}" : "__ANON__";

    my $self  = $class->_new(%args);
    $self->compile_type_constraint()
        unless $self->_has_compiled_type_constraint;
    return $self;
}



sub coerce {
    my $self = shift;

    my $coercion = $self->coercion;

    unless ($coercion) {
        require Moose;
        Moose->throw_error("Cannot coerce without a type coercion");
    }

    return $_[0] if $self->check($_[0]);

    return $coercion->coerce(@_);
}

sub assert_coerce {
    my $self = shift;

    my $coercion = $self->coercion;

    unless ($coercion) {
        require Moose;
        Moose->throw_error("Cannot coerce without a type coercion");
    }

    return $_[0] if $self->check($_[0]);

    my $result = $coercion->coerce(@_);

    $self->assert_valid($result);

    return $result;
}

sub check {
    my ($self, @args) = @_;
    my $constraint_subref = $self->_compiled_type_constraint;
    return $constraint_subref->(@args) ? 1 : undef;
}

sub validate {
    my ($self, $value) = @_;
    if ($self->_compiled_type_constraint->($value)) {
        return undef;
    }
    else {
        $self->get_message($value);
    }
}

sub assert_valid {
    my ($self, $value) = @_;

    my $error = $self->validate($value);
    return 1 if ! defined $error;

    require Moose;
    Moose->throw_error($error);
}

sub get_message {
    my ($self, $value) = @_;
    if (my $msg = $self->message) {
        local $_ = $value;
        return $msg->($value);
    }
    else {
        # have to load it late like this, since it uses Moose itself
        my $can_partialdump = try {
            # versions prior to 0.14 had a potential infinite loop bug
            Class::MOP::load_class('Devel::PartialDump', { -version => 0.14 });
            1;
        };
        if ($can_partialdump) {
            $value = Devel::PartialDump->new->dump($value);
        }
        else {
            $value = (defined $value ? overload::StrVal($value) : 'undef');
        }
        return "Validation failed for '" . $self->name . "' with value $value";
    }
}

## type predicates ...

sub equals {
    my ( $self, $type_or_name ) = @_;

    my $other = Moose::Util::TypeConstraints::find_type_constraint($type_or_name) or return;

    return 1 if $self == $other;

    if ( $self->has_hand_optimized_type_constraint and $other->has_hand_optimized_type_constraint ) {
        return 1 if $self->hand_optimized_type_constraint == $other->hand_optimized_type_constraint;
    }

    return unless $self->constraint == $other->constraint;

    if ( $self->has_parent ) {
        return unless $other->has_parent;
        return unless $self->parent->equals( $other->parent );
    } else {
        return if $other->has_parent;
    }

    return;
}

sub is_a_type_of {
    my ($self, $type_or_name) = @_;

    my $type = Moose::Util::TypeConstraints::find_type_constraint($type_or_name) or return;

    ($self->equals($type) || $self->is_subtype_of($type));
}

sub is_subtype_of {
    my ($self, $type_or_name) = @_;

    my $type = Moose::Util::TypeConstraints::find_type_constraint($type_or_name) or return;

    my $current = $self;

    while (my $parent = $current->parent) {
        return 1 if $parent->equals($type);
        $current = $parent;
    }

    return 0;
}

## compiling the type constraint

sub compile_type_constraint {
    my $self = shift;
    $self->_compiled_type_constraint($self->_actually_compile_type_constraint);
}

## type compilers ...

sub _actually_compile_type_constraint {
    my $self = shift;

    return $self->_compile_hand_optimized_type_constraint
        if $self->has_hand_optimized_type_constraint;

    my $check = $self->constraint;
    unless ( defined $check ) {
        require Moose;
        Moose->throw_error( "Could not compile type constraint '"
                . $self->name
                . "' because no constraint check" );
    }

    return $self->_compile_subtype($check)
        if $self->has_parent;

    return $self->_compile_type($check);
}

sub _compile_hand_optimized_type_constraint {
    my $self = shift;

    my $type_constraint = $self->hand_optimized_type_constraint;

    unless ( ref $type_constraint ) {
        require Moose;
        Carp::confess ("Hand optimized type constraint for " . $self->name . " is not a code reference");
        Moose->throw_error("Hand optimized type constraint is not a code reference");
    }

    return $type_constraint;
}

sub _compile_subtype {
    my ($self, $check) = @_;

    # gather all the parent constraintss in order
    my @parents;
    my $optimized_parent;
    foreach my $parent ($self->_collect_all_parents) {
        # if a parent is optimized, the optimized constraint already includes
        # all of its parents tcs, so we can break the loop
        if ($parent->has_hand_optimized_type_constraint) {
            push @parents => $optimized_parent = $parent->hand_optimized_type_constraint;
            last;
        }
        else {
            push @parents => $parent->constraint;
        }
    }

    @parents = grep { $_ != $null_constraint } reverse @parents;

    unless ( @parents ) {
        return $self->_compile_type($check);
    } elsif( $optimized_parent and @parents == 1 ) {
        # the case of just one optimized parent is optimized to prevent
        # looping and the unnecessary localization
        if ( $check == $null_constraint ) {
            return $optimized_parent;
        } else {
            return subname($self->name, sub {
                return undef unless $optimized_parent->($_[0]);
                my (@args) = @_;
                local $_ = $args[0];
                $check->(@args);
            });
        }
    } else {
        # general case, check all the constraints, from the first parent to ourselves
        my @checks = @parents;
        push @checks, $check if $check != $null_constraint;
        return subname($self->name => sub {
            my (@args) = @_;
            local $_ = $args[0];
            foreach my $check (@checks) {
                return undef unless $check->(@args);
            }
            return 1;
        });
    }
}

sub _compile_type {
    my ($self, $check) = @_;

    return $check if $check == $null_constraint; # Item, Any

    return subname($self->name => sub {
        my (@args) = @_;
        local $_ = $args[0];
        $check->(@args);
    });
}

## other utils ...

sub _collect_all_parents {
    my $self = shift;
    my @parents;
    my $current = $self->parent;
    while (defined $current) {
        push @parents => $current;
        $current = $current->parent;
    }
    return @parents;
}

sub create_child_type {
    my ($self, %opts) = @_;
    my $class = ref $self;
    return $class->new(%opts, parent => $self);
}

1;

# ABSTRACT: The Moose Type Constraint metaclass



=pod

=head1 NAME

Moose::Meta::TypeConstraint - The Moose Type Constraint metaclass

=head1 VERSION

version 2.0007

=head1 DESCRIPTION

This class represents a single type constraint. Moose's built-in type
constraints, as well as constraints you define, are all stored in a
L<Moose::Meta::TypeConstraint::Registry> object as objects of this
class.

=head1 INHERITANCE

C<Moose::Meta::TypeConstraint> is a subclass of L<Class::MOP::Object>.

=head1 METHODS

=over 4

=item B<< Moose::Meta::TypeConstraint->new(%options) >>

This creates a new type constraint based on the provided C<%options>:

=over 8

=item * name

The constraint name. If a name is not provided, it will be set to
"__ANON__".

=item * parent

A C<Moose::Meta::TypeConstraint> object which is the parent type for
the type being created. This is optional.

=item * constraint

This is the subroutine reference that implements the actual constraint
check. This defaults to a subroutine which always returns true.

=item * message

A subroutine reference which is used to generate an error message when
the constraint fails. This is optional.

=item * coercion

A L<Moose::Meta::TypeCoercion> object representing the coercions to
the type. This is optional.

=item * optimized

This is a variant of the C<constraint> parameter that is somehow
optimized. Typically, this means incorporating both the type's
constraint and all of its parents' constraints into a single
subroutine reference.

=back

=item B<< $constraint->equals($type_name_or_object) >>

Returns true if the supplied name or type object is the same as the
current type.

=item B<< $constraint->is_subtype_of($type_name_or_object) >>

Returns true if the supplied name or type object is a parent of the
current type.

=item B<< $constraint->is_a_type_of($type_name_or_object) >>

Returns true if the given type is the same as the current type, or is
a parent of the current type. This is a shortcut for checking
C<equals> and C<is_subtype_of>.

=item B<< $constraint->coerce($value) >>

This will attempt to coerce the value to the type. If the type does not
have any defined coercions this will throw an error.

If no coercion can produce a value matching C<$constraint>, the original
value is returned.

=item B<< $constraint->assert_coerce($value) >>

This method behaves just like C<coerce>, but if the result is not valid
according to C<$constraint>, an error is thrown.

=item B<< $constraint->check($value) >>

Returns true if the given value passes the constraint for the type.

=item B<< $constraint->validate($value) >>

This is similar to C<check>. However, if the type I<is valid> then the
method returns an explicit C<undef>. If the type is not valid, we call
C<< $self->get_message($value) >> internally to generate an error
message.

=item B<< $constraint->assert_valid($value) >>

Like C<check> and C<validate>, this method checks whether C<$value> is
valid under the constraint.  If it is, it will return true.  If it is not,
an exception will be thrown with the results of
C<< $self->get_message($value) >>.

=item B<< $constraint->name >>

Returns the type's name, as provided to the constructor.

=item B<< $constraint->parent >>

Returns the type's parent, as provided to the constructor, if any.

=item B<< $constraint->has_parent >>

Returns true if the type has a parent type.

=item B<< $constraint->parents >>

A synonym for C<parent>. This is useful for polymorphism with types
that can have more than one parent.

=item B<< $constraint->constraint >>

Returns the type's constraint, as provided to the constructor.

=item B<< $constraint->get_message($value) >>

This generates a method for the given value. If the type does not have
an explicit message, we generate a default message.

=item B<< $constraint->has_message >>

Returns true if the type has a message.

=item B<< $constraint->message >>

Returns the type's message as a subroutine reference.

=item B<< $constraint->coercion >>

Returns the type's L<Moose::Meta::TypeCoercion> object, if one
exists.

=item B<< $constraint->has_coercion >>

Returns true if the type has a coercion.

=item B<< $constraint->hand_optimized_type_constraint >>

Returns the type's hand optimized constraint, as provided to the
constructor via the C<optimized> option.

=item B<< $constraint->has_hand_optimized_type_constraint >>

Returns true if the type has an optimized constraint.

=item B<< $constraint->create_child_type(%options) >>

This returns a new type constraint of the same class using the
provided C<%options>. The C<parent> option will be the current type.

This method exists so that subclasses of this class can override this
behavior and change how child types are created.

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

