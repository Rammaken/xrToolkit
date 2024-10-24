package Moose::Meta::Method::Accessor::Native::Array::get;
BEGIN {
  $Moose::Meta::Method::Accessor::Native::Array::get::AUTHORITY = 'cpan:STEVAN';
}
BEGIN {
  $Moose::Meta::Method::Accessor::Native::Array::get::VERSION = '2.0007';
}

use strict;
use warnings;

use Class::MOP::MiniTrait;

use Moose::Role;

with 'Moose::Meta::Method::Accessor::Native::Reader' => {
    -excludes => [
        qw(
            _minimum_arguments
            _maximum_arguments
            _inline_check_arguments
            )
    ],
    },
    'Moose::Meta::Method::Accessor::Native::Array';

sub _minimum_arguments { 1 }

sub _maximum_arguments { 1 }

sub _inline_check_arguments {
    my $self = shift;

    return $self->_inline_check_var_is_valid_index('$_[0]');
}

sub _return_value {
    my $self = shift;
    my ($slot_access) = @_;

    return $slot_access . '->[ $_[0] ]';
}

1;
