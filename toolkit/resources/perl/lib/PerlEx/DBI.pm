# based on Apache::DBI
# modified by Shane Caraveo <ShaneC@ActiveState.com> for use with PerlEx

package PerlEx::DBI;

# DBI has Apache::DBI hardcoded in it, so trick it into thinking that
# we're Apache::DBI
BEGIN {
    $INC{'Apache/DBI.pm'} = "PerlEx/DBI.pm";
    $ENV{MOD_PERL} = 1;
    # $ENV{GATEWAY_INTERFACE} already matches /^CGI-Perl/
    require DBI;
    DBI->import();
    delete $INC{'Apache/DBI.pm'};

    sub connect;
    *Apache::DBI::connect = \&connect;
}

use strict;

require_version DBI 1.14;

# $Id: DBI.pm,v 1.45 2001/01/12 18:59:00 mergl Exp $
BEGIN {
    # these functions aren't available when testing standalone (not running
    # under PerlEx)
    $PerlEx::DBI::DEBUG = defined(&PerlEx::Trace) ? PerlEx::Trace() : 5 ;
    $PerlEx::DBI::VERSION = '0.1';
}

sub dbg {
    print STDERR "PerlEx::DBI: ",  @_;
}

my %Connected;    # cache for database handles
my %Rollback;     # keeps track of pushed PerlCleanupHandler which can do a rollback after the request has finished
my %PingTimeOut;  # stores the timeout values per data_source, a negative value de-activates ping, default = 0
my %LastPingTime; # keeps track of last ping per data_source
my $Idx;          # key of %Connected and %Rollback.

# supposed to be called in a startup script.
# stores the timeout per data_source for the ping function.
# use a DSN without attribute settings specified within !

sub setPingTimeOut { 
    my $class       = shift;
    my $data_source = shift;
    my $timeout     = shift;
    # sanity check
    if ($data_source =~ /dbi:\w+:.*/ and $timeout =~ /\-*\d+/) {
        $PingTimeOut{$data_source} = $timeout;
    }
}


# the connect method called from DBI::connect

sub connect {
    my $class = shift;
    unshift @_, $class if ref $class;
    my $drh    = shift;
    my @args   = map { defined $_ ? $_ : "" } @_;
    my $dsn    = "dbi:$drh->{Name}:$args[0]";
    my $prefix = "$$ PerlEx::DBI            ";

    $Idx = join $;, $args[0], $args[1], $args[2];

    # the hash-reference differs between calls even in the same
    # process, so de-reference the hash-reference 
    if (3 == $#args and ref $args[3] eq "HASH") {
       my ($key, $val);
       while (($key,$val) = each %{$args[3]}) {
           $Idx .= "$;$key=$val";
       }
    } elsif (3 == $#args) {
        pop @args;
    }

    # this PerlCleanupHandler is supposed to initiate a rollback after the script has finished if AutoCommit is off.
    my $needCleanup = ($Idx =~ /AutoCommit[^\d]+0/) ? 1 : 0;
    
    if(!$Rollback{$Idx} and $needCleanup and defined(&PerlEx::Precompiler::PerlCleanupHandler)) {
        print STDERR "$prefix push PerlCleanupHandler \n" if $PerlEx::DBI::DEBUG > 1;
        PerlEx::Precompiler::PerlCleanupHandler(\&cleanup);
        # make sure, that the rollback is called only once for every 
        # request, even if the script calls connect more than once
        $Rollback{$Idx} = 1;
    }

    # do we need to ping the database ?
    $PingTimeOut{$dsn}  = 0 unless $PingTimeOut{$dsn};
    $LastPingTime{$dsn} = 0 unless $LastPingTime{$dsn};
    my $now = time;
    my $needping = (($PingTimeOut{$dsn} == 0 or $PingTimeOut{$dsn} > 0) and $now - $LastPingTime{$dsn} > $PingTimeOut{$dsn}) ? 1 : 0;
    dbg "$prefix need ping: ", $needping == 1 ? "yes" : "no", "\n" if $PerlEx::DBI::DEBUG > 1;
    $LastPingTime{$dsn} = $now;

    # check first if there is already a database-handle cached
    # if this is the case, possibly verify the database-handle 
    # using the ping-method. Use eval for checking the connection 
    # handle in order to avoid problems (dying inside ping) when 
    # RaiseError being on and the handle is invalid.
    if ($Connected{$Idx} and (!$needping or eval{$Connected{$Idx}->ping})) {
        dbg "$prefix already connected to '$Idx'\n" if $PerlEx::DBI::DEBUG > 1;
        return (bless $Connected{$Idx}, 'PerlEx::DBI::db');
    }

    # either there is no database handle-cached or it is not valid,
    # so get a new database-handle and store it in the cache
    delete $Connected{$Idx};
    $Connected{$Idx} = $drh->connect(@args);
    return undef if !$Connected{$Idx};

    # return the new database handle
    dbg "$prefix new connect to '$Idx'\n" if $PerlEx::DBI::DEBUG;
    return (bless $Connected{$Idx}, 'PerlEx::DBI::db');
}

# The PerlCleanupHandler is supposed to initiate a rollback after the script has finished if AutoCommit is off.
# Note: the PerlCleanupHandler runs after the response has been sent to the client

sub cleanup {
    my $prefix = "$$ PerlEx::DBI            ";
    dbg "$prefix PerlCleanupHandler \n" if $PerlEx::DBI::DEBUG > 1;
    my $dbh = $Connected{$Idx};
    if ($Rollback{$Idx} and $dbh and $dbh->{Active} and !$dbh->{AutoCommit} and eval {$dbh->rollback}) {
        dbg "$prefix PerlCleanupHandler rollback for $Idx \n" if $PerlEx::DBI::DEBUG > 1;
    }
    delete $Rollback{$Idx};
    1;
}


# This function can be called from other handlers to perform tasks on all cached database handles.

sub all_handlers {
  return \%Connected;
}


# patch from Tim Bunce: PerlEx::DBI will not return a DBD ref cursor

@PerlEx::DBI::st::ISA = ('DBI::st');


# overload disconnect

{ package PerlEx::DBI::db;
  no strict;
  @ISA=qw(DBI::db);
  use strict;
  sub disconnect {
      my $prefix = "$$ PerlEx::DBI            ";
      PerlEx::DBI::dbg "$prefix disconnect (overloaded) \n" if $PerlEx::DBI::DEBUG > 1;
      1;
  };
}

# used for debugging
sub status {
    print "in PerlEx::DBI::status\n";
    my($r, $q) = @_;
    print qw(<TABLE><TR><TD>Datasource</TD><TD>Username</TD></TR>);
    for (keys %Connected) {
        print '<TR><TD>', join('</TD><TD>', (split($;, $_))[0,1]), "</TD></TR>\n";
    }
    print '</TABLE>';
}


1;

__END__


=head1 NAME

PerlEx::DBI - Initiate a persistent database connection

=head1 SYNOPSIS

    # add this switch to CommandLineOptions setting in Interpreter Class
    -mPerlEx::DBI

    # or add next line to StartupCode setting in the Interpreter Class
    use PerlEx::DBI ();  # this comes before all other modules using DBI

Note to Apache users: PerlEx::DBI is based on Apache::DBI.  Except for
the configuration noted above, PerlEx::DBI is functionally identical
to Apache::DBI.

You do NOT need to change anything in your scripts. The usage of this
module is absolutely transparent!

=head1 DESCRIPTION

This module transparently initiates persistent database connections.

The database access must be via the DBI module. For supported DBI drivers
see: 

    http://www.symbolstone.org/technology/perl/DBI/

When the DBI module is loaded by your script (do not confuse this with
the loading of the PerlEx::DBI module itself) DBI looks at the environment
variable GATEWAY_INTERFACE and checks to see if it starts with 'CGI-Perl',
and whether an Apache::DBI compatible module (in this case PerlEx::DBI)
has been loaded.  If that is the case, every connect request will be
forwarded to the Apache::DBI compatible module.

PerlEx::DBI then looks at whether a database handle from a previous
connect request is already cached and whether the cached handle is still
valid, using the ping method.  If these two conditions are fulfilled it 
just returns the cached database handle.  The parameters defining the
connection have to be exactly the same for a cached handle to be selected,
including the connect attributes.  If there is no appropriate database
handle or if the ping method fails, a new connection is established and
the handle is cached for later re-use.  There is no need to remove any
disconnect() calls from your code.  They won't do anything because 
the PerlEx::DBI module overloads the disconnect method.

The PerlEx::DBI module still has a potential limitation: it keeps database
connections persistent on a per-interpreter basis. This means that if a
user accesses a database several times, the http requests may end up
being handled by different PerlEx interpreters, even though PerlEx tries
to use as few interpreters as possible.  In this case, every interpreter
needs to do its own connect.  It would be nice if all interpreters could
share the database handles, but currently this is not possible because of
strict isolation of the data space of interpreters, for scalability
and security reasons.  Also, it is currently not possible to create a
database handle upon PerlEx startup and later inheriting this handle in
every subsequent interpreter.

With these limitations in mind, there may be some scenarios where the usage
of PerlEx::DBI may not be worthwhile.  Consider a heavily loaded web
site where every user connects to the database with a unique userid.
This could cause many database handles to be initialized and kept persistent,
hogging database resources.

If you find that PerlEx::DBI results in consumption of excess database
resources, you should investigate enabling the native connection pooling
features of your database instead of enabling PerlEx::DBI for your scripts.

Another potential problem are timeouts: some databases disconnect the client
after a certain period of inactivity.  PerlEx::DBI normally tries to
validate the database handle using the ping-method of the DBI-module.
This method returns true as default.  If the database handle is not valid
and the driver has no implementation for the ping method, you will get
an error when accessing the database.  To work around this, you can try
to replace the ping method by any database command, which is cheap and
safe, or you may deactivate the usage of the ping method (see CONFIGURATION
below). 

Here is a generalized ping method, which can be added to the driver module:

{   package DBD::xxx::db; # ====== DATABASE ======
    use strict;

    sub ping {
        my($dbh) = @_;
        my $ret = 0;
        eval {
            local $SIG{__DIE__}  = sub { return (0); };
            local $SIG{__WARN__} = sub { return (0); };
            # adapt the select statement to your database:
            $ret = $dbh->do('select 1');
        };
        return ($@) ? 0 : $ret;
    }
}

Transactions: a standard DBI script will automatically perform a rollback
whenever the script exits. In the case of persistent database connections,
the database handle will not be destroyed and hence no automatic rollback 
occurs.  While at first glance it might seem practical to handle a transaction 
over multiple requests, this will not really work because different requests
may be handled by different interpreters.  One interpreter will not know the
state of a specific transaction which has been started by another interpreter.

In general it is good practice to perform an explicit commit or rollback at
the end of every script.  In order to avoid inconsistencies in the database
in case AutoCommit is off and the script finishes without an explicit
rollback, the PerlEx::DBI module uses a cleanup handler to issue a rollback
at the end of every request.  Note that this cleanup handler will only be
used if the initial data_source sets AutoCommit = 0. It will not be used
if AutoCommit is turned off after the connect has been done. 

=head1 CONFIGURATION

PerlEx::DBI should be loaded upon startup of a PerlEx Interpreter Class.
This can be done either by adding the following switch to the
CommandLineOptions registry setting:

    -mPerlEx::DBI

or by adding the following line to the StartupCode setting such that
it executes before anything else that loads the DBI module:
 
    use PerlEx::DBI ();

Either of the above can be set within an Interpreter Class to restrict
the setting to a single script or a set of scripts under a given location.
See the PerlEx documentation for more information on these registry
settings.

Note that it is important to load PerlEx::DBI before any other modules
using DBI!

There is one configuration which is server-specific and which can be done 
within the script after $data_source has been initialized:

    PerlEx::DBI->setPingTimeOut($data_source, $timeout);

This configures the usage of the ping method, to validate a connection. 
Setting the timeout to 0 will always validate the database connection 
using the ping method (default). Setting the timeout < 0 will de-activate
the validation of the database handle. This can be used for drivers which 
do not implement the ping-method. Setting the timeout > 0 will ping the 
database only if the last access was more than timeout seconds before. 

To enable logging, set the Trace value for your Interpreter Class
to 1 or higher.  Setting the variable to 1 simply reports every new
connect.  Setting Trace to 2 enables full debug output.


=head1 PREREQUISITES

Note that this module needs PerlEx 2.2 or higher and DBI 1.14 or higher.

=head1 SEE ALSO

L<DBI>


=head1 AUTHORS

=over

=item *

PerlEx::DBI is a modified version of Apache::DBI.
PerlEx::DBI by Shane Caraveo <ShaneC@ActiveState.com>

=item *

Apache::DBI by Edmund Mergl <E.Mergl@bawue.de>

=item *

DBI by Tim Bunce <dbi-users@isc.org>

=back

=head1 COPYRIGHT

The PerlEx::DBI module is based on Apache::DBI
and is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
