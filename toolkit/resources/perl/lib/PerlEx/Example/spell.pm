package spell;

use strict;

BEGIN {
    my $datafile = ".\\words";
    my $DATA;
    if (open($DATA, "< $datafile")) {
        my $quote;
        while (my $line = readline($DATA)) {
	    $line =~ s/\r\n|\n//;
            $PerlEx::Samples::spell::words{$line}=1;
        }
        close($DATA);
    }
}

sub check {
   my $word = shift;
   return exists $PerlEx::Samples::spell::words{$word} ? 1 : 0;
}

# test code
unless (caller) {
    my $text = check("test") ? "'test' is correct":"'test' is incorrect";
    print $text;
}

1;
