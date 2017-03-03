$lineNo = 0;
while( <> )
{
	++ $lineNo;
	s/[\r\n]//g;
	@info = split / \|\|\| /, $_;
	print $info[0].", ";
	print STDERR "\rprocessed $lineNo lines.";
}
print STDERR "\rprocessed $lineNo lines.\n";
