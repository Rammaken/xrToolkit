@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S %0 %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
if errorlevel 1 goto script_failed_so_exit_with_non_zero_val 2>nul
goto endofperl
@rem ';
#!perl
#line 15
    eval 'exec E:\Workspace\Modding\ACDC Universal\Perl\bin\perl.exe -S $0 ${1+"$@"}'
	if $running_under_some_shell;
#!/usr/bin/perl

=head1 NAME

corelist - a commandline frontend to Module::CoreList

=head1 DESCRIPTION

See L<Module::CoreList> for one.

=head1 SYNOPSIS

    corelist -v
    corelist [-a|-d] <ModuleName> | /<ModuleRegex>/ [<ModuleVersion>] ...
    corelist [-v <PerlVersion>] [ <ModuleName> | /<ModuleRegex>/ ] ...

=head1 OPTIONS

=over

=item -a

lists all versions of the given module (or the matching modules, in case you
used a module regexp) in the perls Module::CoreList knows about.

    corelist -a utf8

    utf8 was first released with perl 5.006
      5.006      undef
      5.006001   undef
      5.006002   undef
      5.007003   1.00
      5.008      1.00
      5.008001   1.02
      5.008002   1.02
      5.008003   1.02
      5.008004   1.03
      5.008005   1.04
      5.008006   1.04
      5.008007   1.05
      5.008008   1.06
      5.009      1.02
      5.009001   1.02
      5.009002   1.04
      5.009003   1.06

=item -d

finds the first perl version where a module has been released by
date, and not by version number (as is the default).

=item -? or -help

help! help! help! to see more help, try --man.

=item -man

all of the help

=item -v

lists all of the perl release versions we got the CoreList for.

If you pass a version argument (value of C<$]>, like C<5.00503> or C<5.008008>),
you get a list of all the modules and their respective versions.
(If you have the C<version> module, you can also use new-style version numbers,
like C<5.8.8>.)

In module filtering context, it can be used as Perl version filter.

=back

As a special case, if you specify the module name C<Unicode>, you'll get
the version number of the Unicode Character Database bundled with the
requested perl versions.

=cut

use Module::CoreList;
use Getopt::Long;
use Pod::Usage;
use strict;
use warnings;

my %Opts;

GetOptions(\%Opts, qw[ help|?! man! v|version:s a! d ] );

pod2usage(1) if $Opts{help};
pod2usage(-verbose=>2) if $Opts{man};

if(exists $Opts{v} ){
    if( !$Opts{v} ) {
        print "\nModule::CoreList has info on the following perl versions:\n";
        print format_perl_version($_)."\n" for sort keys %Module::CoreList::version;
        print "\n";
        exit 0;
    }

    my $num_v = numify_version( $Opts{v} );
    my $version_hash = Module::CoreList->find_version($num_v);

    if( !$version_hash ) {
        print "\nModule::CoreList has no info on perl $Opts{v}\n\n";
        exit 1;
    }

    if ( !@ARGV ) {
	print "\nThe following modules were in perl $Opts{v} CORE\n";
	my $max_mod_len = max_mod_len($version_hash);
	for my $mod ( sort keys %$version_hash ) {
	    printf "%-${max_mod_len}s  %s\n", $mod, $version_hash->{$mod} || "";
	}
	print "\n";
	exit 0;
    }
}

if ( !@ARGV ) {
    pod2usage(0);
}

while (@ARGV) {
	my ($mod, $ver);
	if ($ARGV[0] =~ /=/) {
	    ($mod, $ver) = split /=/, shift @ARGV;
	} else {
	    $mod = shift @ARGV;
	    $ver = (@ARGV && $ARGV[0] =~ /^\d/) ? shift @ARGV : "";
	}

	if ($mod !~ m|^/(.*)/([imosx]*)$|) { # not a regex
	    module_version($mod,$ver);
	} else {
	    my $re;
	    eval { $re = $2 ? qr/(?$2)($1)/ : qr/$1/; }; # trap exceptions while building regex
	    if ($@) {
		# regex errors are usually like 'Quantifier follow nothing in regex; marked by ...'
		# then we drop text after ';' to shorten message
		my $errmsg = $@ =~ /(.*);/ ? $1 : $@;
		warn "\n$mod  is a bad regex: $errmsg\n";
		next;
	    }
	    my @mod = Module::CoreList->find_modules($re);
	    if (@mod) {
		module_version($_, $ver) for @mod;
	    } else {
		$ver |= '';
		print "\n$mod $ver has no match in CORE (or so I think)\n";
	    }

	}
}

exit();

sub module_version {
    my($mod,$ver) = @_;

    if ( $Opts{v} ) {
	my $numeric_v = numify_version($Opts{v});
	my $version_hash = Module::CoreList->find_version($numeric_v);
	if ($version_hash) {
	    print $mod, " ", $version_hash->{$mod} || 'undef', "\n";
	    return;
	}
	else { die "Shouldn't happen" }
    }

    my $ret = $Opts{d}
	? Module::CoreList->first_release_by_date(@_)
	: Module::CoreList->first_release(@_);
    my $msg = $mod;
    $msg .= " $ver" if $ver;

    my $rem = $Opts{d}
	? Module::CoreList->removed_from_by_date($mod)
	: Module::CoreList->removed_from($mod);

    if( defined $ret ) {
        $msg .= " was ";
        $msg .= "first " unless $ver;
        $msg .= "released with perl " . format_perl_version($ret);
        $msg .= " and removed from " . format_perl_version($rem) if $rem;
    } else {
        $msg .= " was not in CORE (or so I think)";
    }

    print "\n",$msg,"\n";

    if(defined $ret and exists $Opts{a} and $Opts{a}){
        display_a($mod);
    }
}


sub max_mod_len {
    my $versions = shift;
    my $max = 0;
    for my $mod (keys %$versions) {
        $max = max($max, length $mod);
    }

    return $max;
}

sub max {
    my($this, $that) = @_;
    return $this if $this > $that;
    return $that;
}

sub display_a {
    my $mod = shift;

    for my $v (grep !/000$/, sort keys %Module::CoreList::version ) {
        next unless exists $Module::CoreList::version{$v}{$mod};

        my $mod_v = $Module::CoreList::version{$v}{$mod} || 'undef';
        printf "  %-10s %-10s\n", format_perl_version($v), $mod_v;
    }
    print "\n";
}


{
    my $have_version_pm;
    sub have_version_pm {
        return $have_version_pm if defined $have_version_pm;
        return $have_version_pm = eval { require version; 1 };
    }
}


sub format_perl_version {
    my $v = shift;
    return $v if $v < 5.006 or !have_version_pm;
    return version->new($v)->normal;
}


sub numify_version {
    my $ver = shift;
    if ($ver =~ /\..+\./) {
	have_version_pm()
	    or die "You need to install version.pm to use dotted version numbers\n";
        $ver = version->new($ver)->numify;
    }
    $ver += 0;
    return $ver;
}

=head1 EXAMPLES

    $ corelist File::Spec

    File::Spec was first released with perl 5.005

    $ corelist File::Spec 0.83

    File::Spec 0.83 was released with perl 5.007003

    $ corelist File::Spec 0.89

    File::Spec 0.89 was not in CORE (or so I think)

    $ corelist File::Spec::Aliens

    File::Spec::Aliens  was not in CORE (or so I think)

    $ corelist /IPC::Open/

    IPC::Open2 was first released with perl 5

    IPC::Open3 was first released with perl 5

    $ corelist /MANIFEST/i

    ExtUtils::Manifest was first released with perl 5.001

    $ corelist /Template/

    /Template/  has no match in CORE (or so I think)

    $ corelist -v 5.8.8 B

    B                        1.09_01

    $ corelist -v 5.8.8 /^B::/

    B::Asmdata               1.01
    B::Assembler             0.07
    B::Bblock                1.02_01
    B::Bytecode              1.01_01
    B::C                     1.04_01
    B::CC                    1.00_01
    B::Concise               0.66
    B::Debug                 1.02_01
    B::Deparse               0.71
    B::Disassembler          1.05
    B::Lint                  1.03
    B::O                     1.00
    B::Showlex               1.02
    B::Stackobj              1.00
    B::Stash                 1.00
    B::Terse                 1.03_01
    B::Xref                  1.01

=head1 COPYRIGHT

Copyright (c) 2002-2007 by D.H. aka PodMaster

Currently maintained by the perl 5 porters E<lt>perl5-porters@perl.orgE<gt>.

This program is distributed under the same terms as perl itself.
See http://perl.org/ or http://cpan.org/ for more info on that.

=cut

__END__
:endofperl
