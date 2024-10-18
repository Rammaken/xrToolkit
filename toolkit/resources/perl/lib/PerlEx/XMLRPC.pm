#!/usr/bin/perl -w

#
# A generic XML-RPC dispatcher for PerlEx.
#

package PerlEx::XMLRPC;
#use Data::Dump qw(dump);

use XC::XMLRPC::Dispatcher;

our %DISPATCHER;

sub Dispatch {
    my $path = $ENV{PATH_TRANSLATED};
    if ($path) {
	unless (exists $DISPATCHER{$path}) {
	    # let it persist!
	    $DISPATCHER{$path} = XC::XMLRPC::Dispatcher->new($path);
	}
	HandleCGI();
    }
    else {
	print <<'EOT';
    Content-type: text/plain

    PerlEx could not determine the directory location for your Web Service
    component.  
    See the PerlEx documentation for more information.
EOT
    }
}

sub HandleCGI {
    die "Not running as CGI" unless $ENV{REQUEST_METHOD};

    if ($ENV{REQUEST_METHOD} eq "GET") {
	serve_html_error("XMLRPC request must be via POST method, not GET!\n");
    }
    elsif ($ENV{REQUEST_METHOD} eq "POST") {
	serve_xmlrpc();
    }
    else {
	serve_html_error("XMLRPC request was neither GET nor POST!\n");
    }
}

sub serve_html_error {
    my $msg = shift || "You need to send me a XMLRPC request!\n";
    print "Content-type: text/plain\r\n\r\n";
    print $msg;
}

sub serve_xmlrpc {
    unless (lc($ENV{CONTENT_TYPE}) =~ m,^text/xml\s*(?:$|;),) {
	# XXX should actually deal with "text/xml; charset=..."
	print "Status: 500 Wrong content type\r\n\r\n";
	return;
    }

    my $len = $ENV{CONTENT_LENGTH};
    if ($len > 8*1024) {
	print "Status: 413 Content too large\r\n\r\n";
	return;
    }

    my $content = "";
    while ($len) {
	my $n = read(*STDIN, $content, $len, length($content));
	die unless $n;
	$len -= $n;
    }

    #warn "----\n$content\n----\n";
    print "Content-type: text/xml\r\n\r\n";

    my $data = $DISPATCHER{$ENV{PATH_TRANSLATED}}->dispatch($content, "");
    #warn "----\n$data\n----\n";
    print $data;

}

1;
