package Moose::Meta::Method::Accessor::Native::Bool::unset;
BEGIN {
  $Moose::Meta::Method::Accessor::Native::Bool::unset::AUTHORITY = 'cpan:STEVAN';
}
BEGIN {
  $Moose::Meta::Method::Accessor::Native::Bool::unset::VERSION = '2.0007';
}

use strict;
use warnings;

use Moose::Role;

with 'Moose::Meta::Method::Accessor::Native::Writer' => {
    -excludes => [
        qw(
            _maximum_arguments
            _inline_optimized_set_new_value
            )
    ]
};

sub _maximum_arguments { 0 }

sub _potential_value { 0 }

sub _inline_optimized_set_new_value {
    my $self = shift;
    my ($inv, $new, $slot_access) = @_;

    return $slot_access . ' = 0;';
}

no Moose::Role;

1;
