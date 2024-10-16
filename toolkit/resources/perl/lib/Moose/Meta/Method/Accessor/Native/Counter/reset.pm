package Moose::Meta::Method::Accessor::Native::Counter::reset;
BEGIN {
  $Moose::Meta::Method::Accessor::Native::Counter::reset::AUTHORITY = 'cpan:STEVAN';
}
BEGIN {
  $Moose::Meta::Method::Accessor::Native::Counter::reset::VERSION = '2.0007';
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

sub _potential_value {
    my $self = shift;
    my ($slot_access) = @_;

    my $attr = $self->associated_attribute;

    return '(do { '
             . join(' ', $attr->_inline_generate_default(
                   '$self', '$default_for_reset'
               )) . ' '
             . '$default_for_reset; '
         . '})';
}

sub _inline_optimized_set_new_value {
    my $self = shift;
    my ($inv, $new, $slot_access) = @_;

    return $slot_access . ' = ' . $self->_potential_value . ';';
}

no Moose::Role;

1;
