package Moose::Meta::TypeConstraint::DuckType;
BEGIN {
  $Moose::Meta::TypeConstraint::DuckType::AUTHORITY = 'cpan:STEVAN';
}
BEGIN {
  $Moose::Meta::TypeConstraint::DuckType::VERSION = '2.0007';
}

use strict;
use warnings;
use metaclass;

use Scalar::Util 'blessed';
use List::MoreUtils qw(all);
use Moose::Util 'english_list';

use Moose::Util::TypeConstraints ();

use base 'Moose::Meta::TypeConstraint';

__PACKAGE__->meta->add_attribute('methods' => (
    accessor => 'methods',
));

sub new {
    my ( $class, %args ) = @_;

    $args{parent} = Moose::Util::TypeConstraints::find_type_constraint('Object');

    my $self = $class->_new(\%args);

    $self->compile_type_constraint()
        unless $self->_has_compiled_type_constraint;

    return $self;
}

sub equals {
    my ( $self, $type_or_name ) = @_;

    my $other = Moose::Util::TypeConstraints::find_type_constraint($type_or_name);

    return unless $other->isa(__PACKAGE__);

    my @self_methods  = sort @{ $self->methods };
    my @other_methods = sort @{ $other->methods };

    return unless @self_methods == @other_methods;

    while ( @self_methods ) {
        my $method = shift @self_methods;
        my $other_method = shift @other_methods;

        return unless $method eq $other_method;
    }

    return 1;
}

sub constraint {
    my $self = shift;

    my @methods = @{ $self->methods };

    return sub {
        my $obj = shift;
        return all { $obj->can($_) } @methods
    };
}

sub _compile_hand_optimized_type_constraint {
    my $self  = shift;

    my @methods = @{ $self->methods };

    sub {
        my $obj = shift;

        return blessed($obj)
            && blessed($obj) ne 'Regexp'
            && all { $obj->can($_) } @methods;
    };
}

sub create_child_type {
    my ($self, @args) = @_;
    return Moose::Meta::TypeConstraint->new(@args, parent => $self);
}

sub get_message {
    my $self = shift;
    my ($value) = @_;

    if ($self->has_message) {
        return $self->SUPER::get_message(@_);
    }

    my @methods = grep { !$value->can($_) } @{ $self->methods };
    my $class = blessed $value;
    return $class
         . " is missing methods "
         . english_list(map { "'$_'" } @methods);
}

1;

# ABSTRACT: Type constraint for duck typing



=pod

=head1 NAME

Moose::Meta::TypeConstraint::DuckType - Type constraint for duck typing

=head1 VERSION

version 2.0007

=head1 DESCRIPTION

This class represents type constraints based on an enumerated list of
required methods.

=head1 INHERITANCE

C<Moose::Meta::TypeConstraint::DuckType> is a subclass of
L<Moose::Meta::TypeConstraint>.

=head1 METHODS

=over 4

=item B<< Moose::Meta::TypeConstraint::DuckType->new(%options) >>

This creates a new duck type constraint based on the given
C<%options>.

It takes the same options as its parent, with several
exceptions. First, it requires an additional option, C<methods>. This
should be an array reference containing a list of required method
names. Second, it automatically sets the parent to the C<Object> type.

Finally, it ignores any provided C<constraint> option. The constraint
is generated automatically based on the provided C<methods>.

=item B<< $constraint->methods >>

Returns the array reference of required methods provided to the
constructor.

=item B<< $constraint->create_child_type >>

This returns a new L<Moose::Meta::TypeConstraint> object with the type
as its parent.

Note that it does I<not> return a C<Moose::Meta::TypeConstraint::DuckType>
object!

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


