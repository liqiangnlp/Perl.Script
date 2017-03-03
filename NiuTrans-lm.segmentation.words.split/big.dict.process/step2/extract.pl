$lineNo = 0;
while( <STDIN> )
{
    ++$lineNo;
	s/[\r\n]//g;
	if( length( $_ ) > 8 )
	{
	    print $_."\n";
	}
	print STDERR "\r$lineNo" if ( $lineNo % 10000 == 0 );
}
print STDERR "\r$lineNo\n";