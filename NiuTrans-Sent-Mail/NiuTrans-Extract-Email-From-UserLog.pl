use strict;

if( scalar( @ARGV ) != 2 )
{
    print STDERR "[USAGE]\n".
                 "       perl NiuTrans-Extract-Email-From-UserLog.pl USERLOG MAILLIST\n";
    exit( 1 );
}

open( USERLOG, "<", $ARGV[ 0 ] ) or die "Error: can not open file $ARGV[ 0 ]!\n";
open( MAILLIST, ">", $ARGV[ 1 ] ) or die "Error: can not open file $ARGV[ 1 ]!\n";

my $lineNo = 0;
my %maillist;
print STDERR "USERLOG:\n";
while( <USERLOG> )
{
    ++$lineNo;
    s/[\r\n]//g;
    if( $_ =~ /(?:.*),(?:.*),(?:.*),(?:.*),(?:.*),(.*),(?:.*),(?:.*),(?:.*)/ )
    {
        ++$maillist{ $1 };
    }
    print STDERR "\r\tProcessed $lineNo lines!" if( $lineNo % 100 == 0 );
}
print STDERR "\r\tProcessed $lineNo lines!\n";

my $key;
my $value;
$lineNo = 0;
print STDERR "MAILLIST:\n";
while( ( $key, $value ) = each %maillist )
{
    ++$lineNo;
    print MAILLIST "$key \|\|\| $value\n";
    print STDERR "\r\tHaving $lineNo Email Address!" if( $lineNo % 100 == 0 );
}
print STDERR "\r\tHaving $lineNo Email Address!\n";

close( USERLOG );
close( MAILLIST );