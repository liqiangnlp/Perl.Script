$lineNo = 0;

while( <STDIN> )
{
    ++$lineNo;
	s/[\r\n]//g;
	if( /(.*) \|\|\| (.*) \|\|\| (.*) \|\|\| (.*) \|\|\| (.*)/ )
	{
	    if( $5 eq 1 )
		{
		    next;
		}
		else
		{
		    print $_."\n";
		}
	}
	
	print STDERR "\r$lineNo" if( $lineNo % 10000 == 0 );
}
print STDERR "\r$lineNo\n";