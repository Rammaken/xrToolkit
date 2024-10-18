#!/usr/bin/env perl

use strict;

use Getopt::Long;

my $curr_script = '(unknown)';
my %opened_files = ();
my %closed_files = ();
my %opts = ();

GetOptions(\%opts, 'h|help') or usage();
usage() if $opts{'h'};

foreach my $file (@ARGV) {
    process_log($file);
}

# Now, go through opened_files and see which are still open.

my $nopened = 0;

print "\nRemaining Open Files:\n" if scalar(keys %opened_files);
foreach my $key (keys %opened_files) {
    $nopened++;
    print "$key:\n";
    print "  current script: $opened_files{$key}->{'curr_script'}\n";
    print "  file name: $opened_files{$key}->{'filename'}\n";
    print "  fileno: $opened_files{$key}->{'fileno'}\n";
    print "  open operation: $opened_files{$key}->{'open_op'}\n";
    print "  opened by: $opened_files{$key}->{'opened_by'}\n\n";
}

print "Number of files still open: $nopened\n";

exit 0;

sub handle_fclose {
    my ($file, $line, $lineno) = @_;

    if ($line =~ /^fclose\(\) FILE=(\S+) fileno=(\d+) status=([-0-9]+)/) {
	my $file_ptr = $1;
	my $file_no = $2;
	my $status = $3;
	my $caller_file = '(unknown)';
	my $caller_lineno = '(unknown)';

	if ($line =~ / at (.*)? line (\d+)/) {
	    $caller_file = $1;
	    $caller_lineno = $2;
	}

	# Find the entry in the opened_files hash corresponding
	# to this file, and move it to the closed_files hash.

	if (exists($opened_files{$file_ptr})) {
	    $closed_files{$file_ptr} = $opened_files{$file_ptr};

	    # XXX can file_ptr match but file_no be different?

	    $closed_files{$file_ptr}->{'closed_by'} =
		"$caller_file:$caller_lineno";
	    $closed_files{$file_ptr}->{'close_op'} = 'fclose';
	    $closed_files{$file_ptr}->{'status'} = $status;

	    delete $opened_files{$file_ptr};

	} else {
	    warn "NOTICE: closing file not known to have been opened:\n";
	    warn "file: $file\n";
	    warn "line $lineno: $line\n";
	    warn "$file_ptr\n";
	    warn "  current script: $curr_script\n";
	    warn "  fileno: $file_no\n";
	    warn "  open operation: $opened_files{$file_ptr}->{'open_op'}\n";
	    warn "  opened by: $opened_files{$file_ptr}->{'opened_by'}\n";
	    warn "  close operation: fclose\n";

	    if ($caller_file eq '(unknown)') {
		warn "  (most likely closing handles during interpreter unloading)\n\n";
	    } else {
		warn "  closed by: $caller_file:$caller_lineno\n\n";
	    }

	    $closed_files{$file_ptr} = {
		'fileno' => $file_no,
		'status' => $status,
		'closed_by' => "$caller_file:$caller_lineno",
		'close_op' => 'fclose',
	    };
	}

    } else {
	warn "unknown fclose pattern: $line (line $lineno)\n";
    }
}

sub handle_fdopen {
    my ($file, $line, $lineno) = @_;

    if ($line =~ /^fdopen\(\) fileno=(\d+) mode='(\S+)' FILE=(\S+) at (.*)? line (\d+)/) {
	my $file_no = $1;
	my $file_mode = $2;
	my $file_ptr = $3;
	my $caller_file = $4;
	my $caller_lineno = $5;

	# Add an entry to the opened_files hash.  We're only tracking open
	# file handles here, not open file descriptors.
	$opened_files{$file_ptr} = {
	    'curr_script' => $curr_script,
	    'filename' => '(fdopen)',
	    'fileno' => $file_no,
	    'mode' => $file_mode,
	    'opened_by' => "$caller_file:$caller_lineno",
	    'open_op' => 'fdopen',
	};

    } else {
	warn "unknown fdopen pattern: $line (line $lineno)\n";
    }
}

sub handle_fopen {
    my ($file, $line, $lineno) = @_;

    if ($line =~ /^fopen\(\) file='(\S+)' mode='(\S+)' FILE=(\S+) fileno=(\d+) at (.*)? line (\d+)/) {
	my $file_name = $1;
	my $file_mode = $2;
	my $file_ptr = $3;
	my $file_no = $4;
	my $caller_file = $5;
	my $caller_lineno = $6;

        # Add an entry to the opened_files hash.  We're only tracking open
        # file handles here, not open file descriptors.
        $opened_files{$file_ptr} = {
	    'curr_script' => $curr_script,
	    'filename' => $file_name,
            'fileno' => $file_no,
            'mode' => $file_mode,
            'opened_by' => "$caller_file:$caller_lineno",
	    'open_op' => 'fopen',
        };

    } elsif ($line =~ /^fopen\(\) file='(\S+)' mode='(\S+)' FILE=NULL errno=(\d+) at (.*)? line (\d+)/) {

	# XXX Are we interested in this?

    } else {
	warn "unknown fopen pattern: $line (line $lineno)\n";
    }
}

sub handle_freopen {
    my ($file, $line, $lineno) = @_;

    if ($line =~ /^freopen\(\) file='(\S+)' mode='(\S+)' oFILE=(\S+) ofileno=(\d+) FILE=(\S+) fileno=(\d+) at (.*)? line (\d+)/) {
	my $file_name = $1;
	my $file_mode = $2;
	my $old_file_ptr = $3;
	my $old_file_no = $4;
	my $new_file_ptr = $5;
	my $new_file_no = $6;
	my $caller_file = $7;
	my $caller_lineno = $8;

        if (exists($opened_files{$old_file_ptr})) {
            $closed_files{$old_file_ptr} = $opened_files{$old_file_ptr};

            # XXX can file_ptr match but file_no be different?

            $closed_files{$old_file_ptr}->{'closed_by'} =
                "$caller_file:$caller_lineno";
	    $closed_files{$old_file_ptr}->{'close_op'} = 'freopen';

            delete $opened_files{$old_file_ptr};

        } else {
            warn "\nNOTICE: closing file not known to have been opened\n";
	    warn "file: $file\n";
	    warn "line $lineno: $line\n";
            warn "$old_file_ptr\n";
            warn "  current script: $curr_script\n";
            warn "  fileno: $old_file_no\n";
            warn "  open operation: $opened_files{$old_file_ptr}->{'open_op'}\n";
            warn "  opened by: $opened_files{$old_file_ptr}->{'opened_by'}\n";
            warn "  close operation: freopen\n";

            if ($caller_file eq '(unknown)') {
                warn "  (most likely closing handles during interpreter unloadin
g)\n\n";
            } else {
                warn "  closed by: $caller_file:$caller_lineno\n\n";
            }

            $closed_files{$old_file_ptr} = {
                'fileno' => $old_file_no,
                'closed_by' => "$caller_file:$caller_lineno",
		'close_op' => 'freopen',
            };
        }

	# Now, add a new entry, under new_file_ptr, to the opened_files hash.
        $opened_files{$new_file_ptr} = {
	    'curr_script' => $curr_script,
            'filename' => $file_name,
            'fileno' => $new_file_no,
            'mode' => $file_mode,
            'opened_by' => "$caller_file:$caller_lineno",
            'open_op' => 'freopen',
        };

    } elsif ($line = /^freopen\(\) file='(\S+)' mode='(\S+)' oFILE=(\S+) ofileno=(\d+) FILE=NULL errno=(\d+)/) {
	my $file_name = $1;
	my $file_mode = $2;
	my $old_file_ptr = $3;
	my $old_file_no = $4;
	my $errno = $5;

	# XXX Are we interested in this?  The given stream isn't changed...

    } else {
	warn "unknown freopen pattern: $line (line $lineno)\n";
    }
}

sub handle_tmpfile {
    my ($file, $line, $lineno) = @_;

    if ($line =~ /^tmpfile\(\) FILE=(\S+) fileno=(\d+) at (.*)? line (\d+)/) {
	my $file_ptr = $1;
	my $file_no = $2;
	my $caller_file = $3;
	my $caller_lineno = $4;

        $opened_files{$file_ptr} = {
	    'curr_script' => $curr_script,
            'filename' => '(tmpfile)',
            'fileno' => $file_no,
            'opened_by' => "$caller_file:$caller_lineno",
        };

    } else {
	warn "unknown tmpfile pattern: $line (line $lineno)\n";
    }
}

sub process_log {
    my ($file) = @_;

    if (open(my $fh, "< $file")) {
	my $lineno = 0;

	while (my $line = <$fh>) {
	    chomp($line);

	    # Get rid of CRs, too
	    $line =~ s/^M$//;
	    $lineno++;

	    # Look for the name of the script generating this log
	    $curr_script = $1 if ($line =~ /^\*\*\* '(\S+)' log message/);

	    # Look for lines that contain 'FILE=' patterns
	    if ($line =~ /FILE\=/) {

                # Strip a timestamp from line
                $line =~ s/\s*\[.+\]: //;

		# The first word in the log line is the file operation
		$line =~ /^(\S+)\(\)\s+/;

		my $op = $1;

		# The format of the fd logging varies from op to op, so
		# handle each accordingly

		if ($op eq 'fclose') {
		    handle_fclose($file, $line, $lineno);

		} elsif ($op eq 'fdopen') {
		    handle_fdopen($file, $line, $lineno);

		} elsif ($op eq 'fopen') {
		    handle_fopen($file, $line, $lineno);

		} elsif ($op eq 'freopen') {
		    handle_freopen($file, $line, $lineno);

		} elsif ($op eq 'tmpfile') {
		    handle_tmpfile($file, $line, $lineno);

		} else {
		    warn "unknown file operation '$op': $line (line $lineno)\n";
		}
	    }
	}

	close($fh);

    } else {
	warn "unable to open '$file': $!\n";
    }
}

sub usage {
    print <<EOH;

usage: plexalizer.pl log1 log2 ... logN

plexalizer.pl scans the given log files for the file-descriptor tracking log
entries generated by the PerlEx .dll.  It will report on the number of
files that it has determined, from the log entries, have not been explicitly
closed, generating entries that look like:

  7803A7F0:
    current script: C:\\path\\to\\some\\PerlEx\\lib\\test.plex
    file name: (tmpfile)
    fileno: 13
    open operation:
    opened by: C:\\path\\to\\some\\PerlEx\\lib\\test.pm:27

The 'current script' shows the name of the script that is generating the
log entries parsed at the time, and 'opened by' shows the name of the file,
and the line number within that file (the number following the colon) where
the file open/close operation occurred.

EOH

    exit 0;
}
