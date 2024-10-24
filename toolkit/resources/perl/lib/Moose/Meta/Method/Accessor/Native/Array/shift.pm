package Moose::Meta::Method::Accessor::Native::Array::shift;
BEGIN {
  $Moose::Meta::Method::Accessor::Native::Array::shift::AUTHORITY = 'cpan:STEVAN';
}
BEGIN {
  $Moose::Meta::Method::Accessor::Native::Array::shift::VERSION = '2.0007';
}

use strict;
use warnings;

use Moose::Role;

with 'Moose::Meta::Method::Accessor::Native::Array::Writer' => {
    -excludes => [
        qw(
            _maximum_arguments
            _inline_capture_return_value
            _inline_optimized_set_new_value
            _return_value
            )
    ]
};

sub _maximum_arguments { 0 }

sub _adds_members { 0 }

sub _potential_value {
    my $self = shift;
    my ($slot_access) = @_;

    return '[ @{ (' . $slot_access . ') } > 1 '
             . '? @{ (' . $slot_access . ') }[1..$#{ (' . $slot_access . ') }] '
             . ': () ]';
}

sub _inline_capture_return_value {
    my $self = shift;
    my ($slot_access) = @_;

    return 'my $old = ' . $slot_access . '->[0];';
}

sub _inline_optimized_set_new_value {
    my $self = shift;
    my ($inv, $new, $slot_access) = @_;

    return 'shift @{ (' . $slot_access . ') };';
}

sub _return_value {
    my $self = shift;
    my ($slot_access) = @_;

    return '$old';
}

no Moose::Role;

1;
