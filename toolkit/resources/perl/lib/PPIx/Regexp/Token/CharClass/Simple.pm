=head1 NAME

PPIx::Regexp::Token::CharClass::Simple - This class represents a simple character class

=head1 SYNOPSIS

 use PPIx::Regexp::Dumper;
 PPIx::Regexp::Dumper->new( 'qr{\w}smx' )
     ->print();

=head1 INHERITANCE

C<PPIx::Regexp::Token::CharClass::Simple> is a
L<PPIx::Regexp::Token::CharClass|PPIx::Regexp::Token::CharClass>.

C<PPIx::Regexp::Token::CharClass::Simple> has no descendants.

=head1 DESCRIPTION

This class represents one of the simple character classes that can occur
anywhere in a regular expression. This includes not only the truly
simple things like \w, but also Unicode properties.

=head1 METHODS

This class provides no public methods beyond those provided by its
superclass.

=cut

package PPIx::Regexp::Token::CharClass::Simple;

use strict;
use warnings;

use base qw{ PPIx::Regexp::Token::CharClass };

use PPIx::Regexp::Constant qw{
    COOKIE_CLASS MINIMUM_PERL TOKEN_LITERAL TOKEN_UNKNOWN
};

our $VERSION = '0.020';

{

    my %introduced = (
	'\h'	=> '5.009005',	# Before this, parsed as 'h'
	'\v'	=> '5.009005',	# Before this, parsed as 'v'
	'\H'	=> '5.009005',	# Before this, parsed as 'H'
	'\N'	=> '5.011',	# Before this, an error.
	'\V'	=> '5.009005',	# Before this, parsed as 'V'
	'\R'	=> '5.009005',
	'\C'	=> '5.006',
	'\X'	=> '5.006',
    );

    sub perl_version_introduced {
	my ( $self ) = @_;
	my $content = $self->content();
	if ( defined( my $minver = $introduced{$content} ) ) {
	    return $minver;
	}
	if ( $content =~ m/ \A \\ [Pp] /smxg ) {
	    # I must have read perl5113delta and thought this
	    # represented the change they were talking about, but I sure
	    # don't see it now. So, until things become clearer ...
#	    $content =~ m/ \G .*? [\s=-] /smxgc
#		and return '5.011003';
	    return '5.006001';
	}
	return MINIMUM_PERL;
    }

}

sub __PPIX_TOKENIZER__regexp {
    my ( $class, $tokenizer, $character ) = @_;

    my $in_class = $tokenizer->cookie( COOKIE_CLASS );

    if ( $character eq '.' ) {
	$in_class
	    and return $tokenizer->make_token( 1, TOKEN_LITERAL );
	return 1;
    }

    if ( my $accept = $tokenizer->find_regexp(
	    qr{ \A \\ (?:
		[wWsSdDvVhHXRNC] |
		[Pp] \{ \s* \^? [\w:=\s-]+ \}
	    ) }smx
	) ) {
	if ( $in_class ) {
	    my $match = $tokenizer->match();
	    # As of Perl 5.11.5, [\N] is a fatal error.
	    '\\N' eq $match
		and return $tokenizer->make_token(
		    $accept, TOKEN_UNKNOWN );
	    # \R is not recognized inside a character class. It
	    # eventually ends up as a literal.
	    '\\R' eq $match and return;
	}
	return $accept;
    }

    return;
}

1;

__END__

=head1 SUPPORT

Support is by the author. Please file bug reports at
L<http://rt.cpan.org>, or in electronic mail to the author.

=head1 AUTHOR

Thomas R. Wyant, III F<wyant at cpan dot org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2011 by Thomas R. Wyant, III

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl 5.10.0. For more details, see the full text
of the licenses in the directory LICENSES.

This program is distributed in the hope that it will be useful, but
without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=cut

# ex: set textwidth=72 :