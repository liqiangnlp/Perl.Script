############################################################
#   version          : NiuTrans
#   Function         : Extraction
#   Author           : Qiang Li
#   Email            : liqiangneu@gmail.com
#   Date             : 2014-04-18
#   last Modified by :
#     2014-04-18 
##############################################################

use strict;

my $logo =   "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n".
             "#  Word Alignment Format Convert                                   #\n".
             "#                                                        NiuTrans  #\n".
             "#                                           liqiangneu\@gmail.com   #\n".
             "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n";

print STDERR $logo;

my %param;
my %option;

get_parameters( @ARGV );



open( SRCRAWFILE, "<", $param{ "-srcraw" } )  or die "Error: can not open $param{ \"-srcraw\" } file!\n";
open( TGTRAWFILE, "<", $param{ "-tgtraw" } )  or die "Error: can not open $param{ \"-tgtraw\" } file!\n";
open( SRCFILE, "<", $param{ "-src" } ) or die "Error: can not open $param{ \"-src\" } file!\n";
open( TGTFILE, "<", $param{ "-tgt" } ) or die "Error: can not open $param{ \"-tgt\" } file!\n";
open( ALNFILE, "<", $param{ "-aln" } ) or die "Error: can not open $param{ \"-aln\" } file!\n";
open( SRCRAWFILEOUT, ">", $param{ "-srcraw" }.".out" )  or die "Error: can not open $param{ \"-srcraw\" }.out file!\n";
open( TGTRAWFILEOUT, ">", $param{ "-tgtraw" }.".out" )  or die "Error: can not open $param{ \"-tgtraw\" }.out file!\n";
open( SRCFILEOUT, ">", $param{ "-src" }.".out" ) or die "Error: can not open $param{ \"-src\" }.out file!\n";
open( TGTFILEOUT, ">", $param{ "-tgt" }.".out" ) or die "Error: can not open $param{ \"-tgt\" }.out file!\n";
open( ALNFILEOUT, ">", $param{ "-aln" }.".out" ) or die "Error: can not open $param{ \"-aln\" }.out file!\n";
open( LOGFILE, ">", $param{ "-log" } ) or die "Error: can not open $param{ \"-log\" } file!\n";

my $src_line;
my $tgt_line;
my $aln_line;
my $src_raw_line;
my $tgt_raw_line;
my $line_no = 0;
my $format_illegal_no = 0;
my $content_illegal_no = 0;
while( $src_line = <SRCFILE> )
{
	++$line_no;
	$tgt_line = <TGTFILE>;
	$aln_line = <ALNFILE>;
	$src_raw_line = <SRCRAWFILE>;
	$tgt_raw_line = <TGTRAWFILE>;
	
	$src_raw_line =~ s/[\r\n]//g;
	$tgt_raw_line =~ s/[\r\n]//g;
	$src_line =~ s/[\r\n]//g;
	$tgt_line =~ s/[\r\n]//g;
	$aln_line =~ s/[\r\n]//g;
	
	if( $src_line eq "" or $tgt_line eq "" or $aln_line eq "Unaligned_sentence" )
	{
		++$format_illegal_no;
		print LOGFILE "LINE=$line_no FORMAT_ILLEGAL ||| SRC=$src_line ||| TGT=$tgt_line ||| ALN=$aln_line\n";
		next;
	} 
	
	my @src_words = split / +/, $src_line;
	my @tgt_words = split / +/, $tgt_line;
	my @alignments_array = split / \|\|\| /, $aln_line;
	
	if( ( scalar( @tgt_words ) + 1 ) ne scalar( @alignments_array ) )
	{
		++$content_illegal_no;
		print LOGFILE "LINE=$line_no CONTENT_ILLEGAL ||| SRC=$src_line ||| TGT=$tgt_line ||| ALN=$aln_line\n";
		next;
	}
	
	my $out_i = 0;
	my $alignment_string = "";
	my $true_or_false = "true";
	foreach my $alignment ( @alignments_array )
	{
		my @alignment_array = split / +/, $alignment;
		if( ( scalar( @src_words ) + 1 ) eq scalar( @alignment_array ) )
		{
			my $in_j = 0;
			for my $ali ( @alignment_array )
			{
				if( $ali ne "0" )
				{
					if( $out_i eq 0 )
					{
						$alignment_string .= $in_j."-NULL-".$ali." ";
					}
					elsif( $in_j eq 0 )
					{
						$alignment_string .= "NULL-".$out_i."-".$ali." ";
					}
					else
					{
						$alignment_string .= $in_j."-".$out_i."-".$ali." ";
					}
				}
				++$in_j;
			}
		}
		else
		{
			++$content_illegal_no;
			print LOGFILE "LINE=$line_no CONTENT_ILLEGAL ||| SRC=$src_line ||| TGT=$tgt_line ||| ALN=$aln_line\n";
			$true_or_false = "false";
			last;
		}
		++$out_i;
	}

	if( $true_or_false eq "true" )
	{
		$alignment_string =~ s/\s+$//g;
		print ALNFILEOUT "$alignment_string\n";
		print SRCRAWFILEOUT "$src_raw_line\n";
		print TGTRAWFILEOUT "$tgt_raw_line\n";
		print SRCFILEOUT "$src_line\n";
		print TGTFILEOUT "$tgt_line\n";
	}
	
	
	if( $line_no % 1000 == 0 )
	{
		print STDERR "\r  Processed $line_no lines. F_ILL=$format_illegal_no C_ILL=$content_illegal_no";
	}
	
}
print STDERR "\r  Processed $line_no lines. F_ILL=$format_illegal_no C_ILL=$content_illegal_no\n";



close( SRCRAWFILE );
close( TGTRAWFILE );
close( SRCFILE );
close( TGTFILE );
close( ALNFILE );
close( SRCFILEOUT );
close( TGTFILEOUT );
close( ALNFILEOUT );
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
                     "                -srcraw :  source raw file\n".
                     "                -tgtraw :  target raw file\n".
                     "                -src    :  source file\n".
                     "                -tgt    :  target file\n".
                     "                -aln    :  alignment file\n".
                     "                -log    :  log file\n".
                     "[EXAMPLE]\n".
                     "            perl WordAlignment.Format.Convert.pl [-src    FILE]\n".
					 "                                                 [-tgt    FILE]\n".
					 "                                                 [-aln    FILE]\n".
					 "                                                 [-srcraw FILE]\n".
					 "                                                 [-tgtraw FILE]\n".
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
     if( !exists $param{ "-srcraw" } )
     {
         print STDERR "Error: Please assign the '-srcraw' parameter!\n";
         exit( 1 );
     }
     if( !exists $param{ "-tgtraw" } )
     {
         print STDERR "Error: Please assign the '-tgtraw' parameter!\n";
         exit( 1 );
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
     if( !exists $param{ "-log" } )
     {
         print STDERR "Error: Please assign the '-log' parameter!\n";
         exit( 1 );
     }
	 

	 
}

