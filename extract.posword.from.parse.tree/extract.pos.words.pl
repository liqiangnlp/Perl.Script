$lineNo = 0;

while( $word = <STDIN> )
{
    ++$lineNo;
	$word =~ s/[\r\n]//g;
	while( $word =~ /(\([\w\$.,`':\-]+? [\w\-.,'`;]+\)?)(.*)/ )
	{
#	    print $1."\n".$2."\n";
        $posword = $1;
		$word = $2;
		$posword =~ /\((.*) (.*)\)/;
		print "$2\t$1\n";
#        print "[POSWORD=$posword]\t[WORD=$word]\n";
	}
	print STDERR "\r$lineNo" if $lineNo % 1000 == 0;
}
print STDERR "\r$lineNo\n";