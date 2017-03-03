############################################################
#   version          : NiuTrans
#   Function         : Extract Sample
#   Author           : Qiang Li
#   Email            : liqiangneu@gmail.com
#   Date             : 2014-04-18
#   last Modified by :
#     2014-04-18 
##############################################################

use strict;

my $logo =   "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n".
             "#  Extract Sample                                                  #\n".
             "#                                                        NiuTrans  #\n".
             "#                                           liqiangneu\@gmail.com   #\n".
             "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n";

print STDERR $logo;

my %param;
my %option;

get_parameters( @ARGV );

open( SRCFILE, "<", $param{ "-src" } ) or die "Error: can not open $param{ \"-src\" } file!\n";
open( TGTFILE, "<", $param{ "-tgt" } ) or die "Error: can not open $param{ \"-tgt\" } file!\n";
open( ALNFILE, "<", $param{ "-aln" } ) or die "Error: can not open $param{ \"-aln\" } file!\n";
open( OUTFILE, ">", $param{ "-out" } ) or die "Error: can not open $param{ \"-out\" } file!\n";
open( LOGFILE, ">", $param{ "-log" } ) or die "Error: can not open $param{ \"-log\" } file!\n";


my $src_line;
my $tgt_line;
my $aln_line;
my $line_no = 0;

while( $src_line = <SRCFILE> )
{
	++$line_no;
	$tgt_line = <TGTFILE>;
	$aln_line = <ALNFILE>;
	
	$src_line =~ s/[\r\n]//g;
	$tgt_line =~ s/[\r\n]//g;
	$aln_line =~ s/[\r\n]//g;
	
	my @src_words = split / +/, $src_line;
	my @tgt_words = split / +/, $tgt_line;
	my @alignments = split / +/, $aln_line;
	
	my %alignments_hash;
	foreach my $alignment ( @alignments )
	{
		if( $alignment =~ /(.+)-NULL-1/ )
		{
#			print STDERR "$alignment $1 ||| ";
			++$alignments_hash{ $1 };
		}
	}
#	print STDERR "\n";

=pod
	my $key;
	my $value;
	while( ( $key, $value ) = each %alignments_hash )
	{
		print STDERR "$key => $value ||| ";
	}
	print STDERR "\n";
=cut

	my $src_pos = 0;
	foreach my $src_word ( @src_words )
	{
		++$src_pos;
		my $sample_string;
		if( exists $alignments_hash{ $src_pos } )
		{
			print LOGFILE "LINE=$line_no ".$src_pos." ".$src_words[ $src_pos -1 ]." SPURIOUS\n";
			$sample_string .= "SPURIOUS ";
			if( $src_pos >= 3 )
			{
				$sample_string .= "f=".$src_words[ $src_pos - 1 ]." f-1=".$src_words[ $src_pos - 2 ]." f-2=".$src_words[ $src_pos - 3 ];
			} 
			elsif( $src_pos == 2 )
			{
				$sample_string .= "f=".$src_words[ $src_pos - 1 ]." f-1=".$src_words[ $src_pos - 2 ]." f-2=NULL";
			}
			elsif( $src_pos == 1 )
			{
				$sample_string .= "f=".$src_words[ $src_pos - 1 ]." f-1=NULL"." f-2=NULL";
			}
			
			if( $src_pos <= ( scalar( @src_words ) - 2 ) )
			{
				$sample_string .= " f+1=".$src_words[ $src_pos ]." f+2=".$src_words[ $src_pos + 1 ];
			} 
			elsif( $src_pos == ( scalar( @src_words ) - 1 ) )
			{
				$sample_string .= " f+1=".$src_words[ $src_pos ]." f+2=NULL";
			}
			elsif( $src_pos == scalar( @src_words ) )
			{
			$sample_string .= " f+1=NULL"." f+2=NULL";
			}
			
		}
		else
		{
			$sample_string .= "UNSPURIOUS ";
			if( $src_pos >= 3 )
			{
				$sample_string .= "f=".$src_words[ $src_pos - 1 ]." f-1=".$src_words[ $src_pos - 2 ]." f-2=".$src_words[ $src_pos - 3 ];
			} 
			elsif( $src_pos == 2 )
			{
				$sample_string .= "f=".$src_words[ $src_pos - 1 ]." f-1=".$src_words[ $src_pos - 2 ]." f-2=NULL";
			}
			elsif( $src_pos == 1 )
			{
				$sample_string .= "f=".$src_words[ $src_pos - 1 ]." f-1=NULL"." f-2=NULL";
			}
			
			if( $src_pos <= ( scalar( @src_words ) - 2 ) )
			{
				$sample_string .= " f+1=".$src_words[ $src_pos ]." f+2=".$src_words[ $src_pos + 1 ];
			} 
			elsif( $src_pos == ( scalar( @src_words ) - 1 ) )
			{
				$sample_string .= " f+1=".$src_words[ $src_pos ]." f+2=NULL";
			}
			elsif( $src_pos == scalar( @src_words ) )
			{
			$sample_string .= " f+1=NULL"." f+2=NULL";
			}
		}
		print OUTFILE $sample_string."\n";
	}
	

	if( $line_no % 1000 == 0 )
	{
		print STDERR "\r  Processed $line_no lines.";
	}
	
}
print STDERR "\r  Processed $line_no lines.\n";



close( SRCFILE );
close( TGTFILE );
close( ALNFILE );
close( OUTFILE );
close( LOGFILE );






######
# Getting parameters from command
sub get_parameters
{
    if( ( scalar( @_ ) < 2 ) || ( scalar( @_ ) % 2 != 0 ) )
    {
        print STDERR "[USAGE]\n".
                     "            WordAlignment.Format.Convert.pl         [OPTIONS]\n".
                     "[OPTION]\n".
                     "                -src    :  source file\n".
                     "                -tgt    :  target file\n".
                     "                -aln    :  alignment file\n".
					 "                -out    :  output file\n".
                     "                -log    :  log file\n".
                     "[EXAMPLE]\n".
                     "            perl WordAlignment.Format.Convert.pl [-src    FILE]\n".
					 "                                                 [-tgt    FILE]\n".
					 "                                                 [-aln    FILE]\n".
					 "                                                 [-log    FILE]\n";
        exit( 0 );
     }
          
     my $pos;
     for( $pos = 0; $pos < scalar( @_ ); ++$pos )
     {
         my $key = $ARGV[ $pos ];
         ++$pos;
         my $value = $ARGV[ $pos ];
         $param{ $key } = $value;
     }
     if( !exists $param{ "-src" } )
     {
         print STDERR "Error: Please assign the '-src' parameter!\n";
         exit( 1 );
     }
     if( !exists $param{ "-tgt" } )
     {
         print STDERR "Error: Please assign the '-tgt' parameter!\n";
         exit( 1 );
     }
     if( !exists $param{ "-aln" } )
     {
         print STDERR "Error: Please assign the '-aln' parameter!\n";
         exit( 1 );
     }
     if( !exists $param{ "-out" } )
     {
         print STDERR "Error: Please assign the '-aln' parameter!\n";
         exit( 1 );
     }
     if( !exists $param{ "-log" } )
     {
         print STDERR "Error: Please assign the '-log' parameter!\n";
         exit( 1 );
     }
	 

	 
}

