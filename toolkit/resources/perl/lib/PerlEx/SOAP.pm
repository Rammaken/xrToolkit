#!/usr/bin/perl -w

#
# A generic SOAP dispatcher for PerlEx.
#

package PerlEx::SOAP;
#use Data::Dump qw(dump);


use XC::SOAP::Dispatcher;

our %DISPATCHER;
our %WSDL;

sub Dispatch {
    my $path = $ENV{PATH_TRANSLATED};
    if ($path) {
	unless (exists $DISPATCHER{$path}) {
	    # let it persist!
	    $DISPATCHER{$path} = XC::SOAP::Dispatcher->new($path);
	}
	HandleCGI();
    }
    else {
	print <<'EOT';
    Content-type: text/plain

    PerlEx could not determine the directory location(s) for your Web Service.

    See the PerlEx documentation for more information.
EOT
    }
}

sub HandleCGI {
    die "Not running as CGI" unless $ENV{REQUEST_METHOD};
    my $path = $ENV{PATH_INFO} || "";
    $path =~ s,^/+,,;
    $path =~ s,/+$,,;

    #warn "UA: $ENV{HTTP_USER_AGENT}\n";

    if ($ENV{REQUEST_METHOD} eq "GET") {
	if (lc($ENV{QUERY_STRING} || "") eq "wsdl"
	    || ($ENV{HTTP_ACCEPT} || "") eq "text/xml")
	{
	    serve_wsdl();
	}
	else {
	    serve_html();
	}
    }
    elsif ($ENV{REQUEST_METHOD} eq "POST") {
	#print "Content-type: text/plain\n\n";
	serve_soap();
    }
    else {
	die "Don't know what this is";
    }
}

sub serve_html {
    print "Content-type: text/plain\r\n\r\n";
    print "You need to send me a SOAP request!\n";
}

sub serve_wsdl {
    print "Content-type: text/xml\r\n\r\n";
    require XC::SOAP::WSDL;

    require CGI;
    my $q = CGI->new;
    my $base = $q->url(-full => 1);

    my $path = $ENV{PATH_TRANSLATED};
    unless (exists $WSDL{$path}) {
	$WSDL{$path} = $DISPATCHER{$path}->as_WSDL(name => "SOAP",
						   base_uri => $base);
    }
    print $WSDL{$path};
}

sub serve_soap {
    my($cnf) = @_;

    unless (exists $ENV{HTTP_SOAPACTION}) {
	print "Status: 500 Missing SOAPAction header\r\n\r\n";
	return;
    }

    my $soapaction = $ENV{HTTP_SOAPACTION};
    if (!length($soapaction)) {
	$soapaction = undef;
    }
    elsif (($soapaction !~ s/^\"// || $soapaction !~ s/\"$//)) {
	print "Status: 500 SOAPAction [$soapaction] must be quoted\r\n\r\n";
	return;
    }

    my $ctype = lc($ENV{CONTENT_TYPE} || "");
    unless ($ctype) {
	print "Status: 500 Missing content type\r\n\r\n";
	return;
    }

    unless ($ctype =~ s,^text/xml\s*(?:$|;),,) {
	print "Status: 500 Wrong content type; must be text/xml\r\n\r\n";
	return;
    }
    
    my $charset;
    if ($ctype =~ /(?:^|;)\s*charset\s*=\s*(\S+)/) {
	$charset = $1;
	$charset =~ s/["']//g;
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
    my $base_uri = "";  # not really used (see &serve_wsdl)

    my %headers = (base_uri   => $base_uri,
		   soapaction => $soapaction,
		  );

    my($code, $head, $data)
	= $DISPATCHER{$ENV{PATH_TRANSLATED}}->dispatch($content, $charset,
						       \%headers);

    #dump($code, $head, $data);

    print "Status: $code NOT OK\r\n" if $code ne "200";
    for (keys %$head) {
	print "$_: $head->{$_}\r\n";
    }
    print "\r\n";

    print $data;

    #warn $data;
}

1;
