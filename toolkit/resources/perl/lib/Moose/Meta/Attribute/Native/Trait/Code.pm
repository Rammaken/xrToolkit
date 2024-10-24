package Moose::Meta::Attribute::Native::Trait::Code;
BEGIN {
  $Moose::Meta::Attribute::Native::Trait::Code::AUTHORITY = 'cpan:STEVAN';
}
BEGIN {
  $Moose::Meta::Attribute::Native::Trait::Code::VERSION = '2.0007';
}
use Moose::Role;

with 'Moose::Meta::Attribute::Native::Trait';

sub _helper_type { 'CodeRef' }

no Moose::Role;

1;

# ABSTRACT: Helper trait for CodeRef attributes



=pod

=head1 NAME

Moose::Meta::Attribute::Native::Trait::Code - Helper trait for CodeRef attributes

=head1 VERSION

version 2.0007

=head1 SYNOPSIS

  package Foo;
  use Moose;

  has 'callback' => (
      traits  => ['Code'],
      is      => 'ro',
      isa     => 'CodeRef',
      default => sub {
          sub { print "called" }
      },
      handles => {
          call => 'execute',
      },
  );

  my $foo = Foo->new;
  $foo->call;    # prints "called"

=head1 DESCRIPTION

This trait provides native delegation methods for code references.

=head1 DEFAULT TYPE

If you don't provide an C<isa> value for your attribute, it will default to
C<CodeRef>.

=head1 PROVIDED METHODS

=over 4

=item * B<execute(@args)>

Calls the coderef with the given args.

=item * B<execute_method(@args)>

Calls the coderef with the the instance as invocant and given args.

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

