package Moose::Meta::Method::Accessor::Native::Hash::is_empty;
BEGIN {
  $Moose::Meta::Method::Accessor::Native::Hash::is_empty::AUTHORITY = 'cpan:STEVAN';
}
BEGIN {
  $Moose::Meta::Method::Accessor::Native::Hash::is_empty::VERSION = '2.0007';
}

use strict;
use warnings;

use Scalar::Util qw( looks_like_number );

use Moose::Role;

with 'Moose::Meta::Method::Accessor::Native::Reader' =>
    { -excludes => ['_maximum_arguments'] };

sub _maximum_arguments { 0 }

sub _return_value {
    my $self = shift;
    my ($slot_access) = @_;

    return 'scalar keys %{ (' . $slot_access . ') } ? 0 : 1';
}

no Moose::Role;

1;
