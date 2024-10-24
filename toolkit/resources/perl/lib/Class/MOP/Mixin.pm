package Class::MOP::Mixin;
BEGIN {
  $Class::MOP::Mixin::AUTHORITY = 'cpan:STEVAN';
}
BEGIN {
  $Class::MOP::Mixin::VERSION = '2.0007';
}

use strict;
use warnings;

use Scalar::Util 'blessed';

sub meta {
    require Class::MOP::Class;
    Class::MOP::Class->initialize( blessed( $_[0] ) || $_[0] );
}

1;

# ABSTRACT: Base class for mixin classes



=pod

=head1 NAME

Class::MOP::Mixin - Base class for mixin classes

=head1 VERSION

version 2.0007

=head1 DESCRIPTION

This class provides a single method shared by all mixins

=head1 METHODS

This class provides a few methods which are useful in all metaclasses.

=over 4

=item B<< Class::MOP::Mixin->meta >>

This returns a L<Class::MOP::Class> object for the mixin class.

=back

=head1 AUTHOR

Stevan Little <stevan@iinteractive.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Infinity Interactive, Inc..

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

