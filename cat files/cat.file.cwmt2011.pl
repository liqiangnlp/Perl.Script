##
# 7/12/2011
##
use strict;
use warnings;

my @files   = ( 'c.token.baseline' );
my @folders = ( '\\10.10.10.128\d\data\NIST-2012\bilingual-ce-part1-LDC2000T46-HongKongPText-News',
                '\\10.10.10.128\d\data\NIST-2012\bilingual-ce-part1-LDC2000T50-HongKongHansardsParallelText');

if( scalar( @ARGV ) < 1 )
{
	print STDERR "#### CWMT2011 ######## CWMT2011 ######## CWMT2011 ####\n".
                 "##                                                  ##\n".
                 "##  USAGE:  perl  cat.file.cwmt2011.pl  out-folder  ##\n".
                 "##                                                  ##\n".
                 "#### CWMT2011 ######## CWMT2011 ######## CWMT2011 ####\n";
	exit( 1 );
}

my $out_folder = $ARGV[ 0 ];
$out_folder =~ s/\\/\//g;
if( !( $out_folder =~ /\/$/ ) )
{
	$out_folder = $out_folder."/";
}
#print STDERR "OUT-FOLDER:".$out_folder."\n";
print STDERR     "#### CWMT2011 ######## CWMT2011 ######## CWMT2011 ####\n".
                 "##                 START  PROCESSING                ##\n".
                 "#### CWMT2011 ######## CWMT2011 ######## CWMT2011 ####\n\n";

foreach my $f( @files )
{
	open( OUTFILE, ">".$out_folder.$f ) or die "Error: can not open file $out_folder$f!\n";
	print STDERR $out_folder.$f."\n";
	
	my $totalNo = 0;
	foreach my $if( @folders )
	{
		print STDERR "  process: ".$if."/".$f."  ";
		open( INFILE, "<".$if."/".$f ) or die "Error: can not read file $if/$f!\n";
		
		my $lineNo = 0;
		while( <INFILE> )
		{
			++$lineNo;
			++$totalNo;
			s/[\r\n]//g;
			print OUTFILE $_."\n";
			print STDERR "\r  process: ".$if."/".$f."    $lineNo lines!" if( $lineNo % 10000 == 0 );
		}
		print STDERR "\r  process: ".$if."/".$f."    $lineNo lines!\n";
		close( INFILE );
	}
	print STDERR "  total  : $totalNo lines!\n\n";

	close( OUTFILE );
}

print STDERR "#### CWMT2011 ######## CWMT2011 ######## CWMT2011 ####\n".
             "##                 PROCESSING  OVER                 ##\n".
             "#### CWMT2011 ######## CWMT2011 ######## CWMT2011 ####\n";
