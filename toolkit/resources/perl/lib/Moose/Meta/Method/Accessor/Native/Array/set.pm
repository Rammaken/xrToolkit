package Moose::Meta::Method::Accessor::Native::Array::set;
BEGIN {
  $Moose::Meta::Method::Accessor::Native::Array::set::AUTHORITY = 'cpan:STEVAN';
}
BEGIN {
  $Moose::Meta::Method::Accessor::Native::Array::set::VERSION = '2.0007';
}

use strict;
use warnings;

use Moose::Role;

with 'Moose::Meta::Method::Accessor::Native::Array::Writer' => {
    -excludes => [
        qw(
            _minimum_arguments
            _maximum_arguments
            _inline_check_arguments
            _inline_coerce_new_values
            _new_members
            _inline_optimized_set_new_value
            _return_value
            )
    ]
};

sub _minimum_arguments { 2 }

sub _maximum_arguments { 2 }

sub _inline_check_arguments {
    my $self = shift;

    return $self->_inline_check_var_is_valid_index('$_[0]');
}

sub _adds_members { 1 }

sub _potential_value {
    my $self = shift;
    my ($slot_access) = @_;

    return '(do { '
             . 'my @potential = @{ (' . $slot_access . ') }; '
             . '$potential[$_[0]] = $_[1]; '
             . '\@potential; '
         . '})';
}

# We need to override this because while @_ can be written to, we cannot write
# directly to $_[1].
sub _inline_coerce_new_values {
    my $self = shift;

    return unless $self->associated_attribute->should_coerce;

    return unless $self->_tc_member_type_can_coerce;

    return '@_ = ($_[0], $member_tc_obj->coerce($_[1]));';
};

sub _new_members { '$_[1]' }

sub _inline_optimized_set_new_value {
    my $self = shift;
    my ($inv, $new, $slot_access) = @_;

    return $slot_access . '->[$_[0]] = $_[1];';
}

sub _return_value {
    my $self = shift;
    my ($slot_access) = @_;

    return $slot_access . '->[$_[0]]';
}

no Moose::Role;

1;
