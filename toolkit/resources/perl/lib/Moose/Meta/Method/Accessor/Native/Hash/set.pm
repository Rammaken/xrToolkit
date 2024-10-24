package Moose::Meta::Method::Accessor::Native::Hash::set;
BEGIN {
  $Moose::Meta::Method::Accessor::Native::Hash::set::AUTHORITY = 'cpan:STEVAN';
}
BEGIN {
  $Moose::Meta::Method::Accessor::Native::Hash::set::VERSION = '2.0007';
}

use strict;
use warnings;

use List::MoreUtils ();
use Scalar::Util qw( looks_like_number );

use Moose::Role;

with 'Moose::Meta::Method::Accessor::Native::Hash::Writer' => {
    -excludes => [
        qw(
            _minimum_arguments
            _maximum_arguments
            _inline_process_arguments
            _inline_check_arguments
            _inline_coerce_new_values
            _inline_optimized_set_new_value
            _return_value
            )
    ],
};

sub _minimum_arguments { 2 }

sub _maximum_arguments { undef }

around _inline_check_argument_count => sub {
    my $orig = shift;
    my $self = shift;

    return (
        $self->$orig(@_),
        'if (@_ % 2) {',
            $self->_inline_throw_error(
                '"You must pass an even number of arguments to set"',
            ) . ';',
        '}',
    );
};

sub _inline_process_arguments {
    my $self = shift;

    return (
        'my @keys_idx = grep { ! ($_ % 2) } 0..$#_;',
        'my @values_idx = grep { $_ % 2 } 0..$#_;',
    );
}

sub _inline_check_arguments {
    my $self = shift;

    return (
        'for (@keys_idx) {',
            'if (!defined($_[$_])) {',
                $self->_inline_throw_error(
                    '"Hash keys passed to set must be defined"',
                ) . ';',
            '}',
        '}',
    );
}

sub _adds_members { 1 }

# We need to override this because while @_ can be written to, we cannot write
# directly to $_[1].
sub _inline_coerce_new_values {
    my $self = shift;

    return unless $self->associated_attribute->should_coerce;

    return unless $self->_tc_member_type_can_coerce;

    # Is there a simpler way to do this?
    return (
        'my $iter = List::MoreUtils::natatime(2, @_);',
        '@_ = ();',
        'while (my ($key, $val) = $iter->()) {',
            'push @_, $key, $member_tc_obj->coerce($val);',
        '}',
    );
};

sub _potential_value {
    my $self = shift;
    my ($slot_access) = @_;

    return '{ %{ (' . $slot_access . ') }, @_ }';
}

sub _new_members { '@_[ @values_idx ]' }

sub _inline_optimized_set_new_value {
    my $self = shift;
    my ($inv, $new, $slot_access) = @_;

    return '@{ (' . $slot_access . ') }{ @_[@keys_idx] } = @_[@values_idx];';
}

sub _return_value {
    my $self = shift;
    my ($slot_access) = @_;

    return 'wantarray '
             . '? @{ (' . $slot_access . ') }{ @_[@keys_idx] } '
             . ': ' . $slot_access . '->{ $_[$keys_idx[0]] }';
}

no Moose::Role;

1;
