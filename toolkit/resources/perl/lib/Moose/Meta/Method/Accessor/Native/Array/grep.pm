package Moose::Meta::Method::Accessor::Native::Array::grep;
BEGIN {
  $Moose::Meta::Method::Accessor::Native::Array::grep::AUTHORITY = 'cpan:STEVAN';
}
BEGIN {
  $Moose::Meta::Method::Accessor::Native::Array::grep::VERSION = '2.0007';
}

use strict;
use warnings;

use Params::Util ();

use Moose::Role;

with 'Moose::Meta::Method::Accessor::Native::Reader' => {
    -excludes => [
        qw(
            _minimum_arguments
            _maximum_arguments
            _inline_check_arguments
            )
    ]
};

sub _minimum_arguments { 1 }

sub _maximum_arguments { 1 }

sub _inline_check_arguments {
    my $self = shift;

    return (
        'if (!Params::Util::_CODELIKE($_[0])) {',
            $self->_inline_throw_error(
                '"The argument passed to grep must be a code reference"',
            ) . ';',
        '}',
    );
}

sub _return_value {
    my $self = shift;
    my ($slot_access) = @_;

    return 'grep { $_[0]->() } @{ (' . $slot_access . ') }';
}

no Moose::Role;

1;
