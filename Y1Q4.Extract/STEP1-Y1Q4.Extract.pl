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
             "#  Extraction                                                      #\n".
             "#                                                        NiuTrans  #\n".
             "#                                           liqiangneu\@gmail.com  #\n".
             "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n";

print STDERR $logo;

my %param;
my %option;

open( LOGFILE, ">", "LOG.txt" ) or die "Error: can not open LOG.txt file!\n";
open( SRCRAWALL, ">", "src.raw.all" ) or die "Error: can not open src.raw.all file!\n";
open( TRARAWALL, ">", "tra.raw.all" ) or die "Error: can not open tra.raw.all file!\n";
open( SRCTOKALL, ">", "src.token.all" ) or die "Error: can not open src.token.all file!\n";
open( TRATOKALL, ">", "tra.token.all" ) or die "Error: can not open tra.token.all file!\n";
open( ALIGNALL, ">", "align.all" ) or die "Error: can not open align.all file!\n";
 


get_parameters( @ARGV );
read_config_file();

close( LOGFILE );

close( SRCRAWALL );
close( TRARAWALL );
close( SRCTOKALL );
close( TRATOKALL );
close( ALIGNALL  );

my $total_num = 0;





sub read_config_file
{
	open( CONFIGFILE, "<", $param{ "-config" } ) or die "Error: can not open $param{ \"-config\" } file!\n";
	while( <CONFIGFILE> )
	{
		s/[\r\n]//g;
		my @dirs = split /\t+/, $_;
		if( scalar( @dirs ) ne 2 )
		{
			print STDERR "Error: one line in config must have two folder.\n";
			exit( 1 );
		}
		opendir(DIR, $dirs[0]) || die "Can't open directory $dirs[0]"; 
		my @dots = readdir(DIR); 
		if( ! -e $dirs[1] )
		{
			mkdir $dirs[1];
		}
		
		foreach my $dot (@dots)
		{ 
			s/[\r\n]//g;
			if( $dot ne "." and $dot ne ".." )
			{
				print STDERR "FILE=".$dirs[0]."\\".$dot."\n";
				print STDERR "OUTPUT=".$dirs[1]."\\".$dot."\n";
				print LOGFILE "FILE=".$dirs[0]."\\".$dot."\n";
				print LOGFILE "OUTPUT=".$dirs[1]."\\".$dot."\n";
				word_alignment_file_extract( $dirs[0]."\\".$dot, $dirs[1]."\\".$dot );
			}
		} 
		closedir DIR; 
	}
	print "TOTAL=$total_num\n";
}



sub word_alignment_file_extract
{
	open infile,"$_[0]" or die "Error: can not open file $_[0].\n";
	open ouc,">$_[1].chinese.raw" or die "Error: can not open file $_[1].chinese.raw.\n";
	open oue,">$_[1].english.raw";
	open outc,">$_[1].chinese.token";
	open oute,">$_[1].english.token";
	open outa,">$_[1].chn.eng.align";

	my $inline = "";
	my $line_no = 0;
	my $src_raw_num = 0;
	my $src_num = 0;
	my $tra_raw_num = 0;
	my $tra_num = 0;
	my $ali_num = 0;

	while( $inline=<infile> )
	{
		++$line_no;
		$inline =~ s/[\r\n]//g;
		
		if( $inline =~ /<source_raw>(.*)<\/source_raw>/ )
		{
			++$src_raw_num;
			++$total_num;
			print ouc $1."\n";
			print SRCRAWALL $1."\n";
		} 
		if( $inline =~ /<source>(.*)<\/source>/ )
		{
			++$src_num;
			print outc $1."\n";
			print SRCTOKALL $1."\n";
		}
		elsif( $inline =~ /<translation_raw>(.*)<\/translation_raw>/ )
		{
			++$tra_raw_num;
			print oue $1."\n";
			print TRARAWALL $1."\n";
		}
		elsif( $inline =~ /<translation>(.*)<\/translation>/ )
		{
			++$tra_num;
			print oute $1."\n";
			print TRATOKALL $1."\n";
		}
		elsif( $inline =~ /<matrix>/ )
		{
			++$ali_num;
			my $alignment = "";
			while( 1 )
			{	
				$inline = <infile>;
				$inline =~ s/[\r\n]//g;
				$inline =~ s/\s+$//g;
				$inline =~ s/^\s+//g;
				if( $inline =~ /<\/matrix>/ )
				{
					last;
				}
				else
				{
#					print outa $inline." ||| ";
					$alignment .= $inline." ||| ";
				}
			}
			$alignment =~ s/ \|\|\| +$//g;
			print outa $alignment."\n";
			print ALIGNALL $alignment."\n";
		}
		if( $line_no % 1000 == 0 ) 
		{
			print STDERR "\r Processed $line_no lines.";
		}
	}

	my $isright = "true";
	if( ( $src_raw_num ne $src_num ) or ( $src_raw_num ne $tra_raw_num ) or ( $src_raw_num ne $tra_num ) or ( $src_raw_num ne $ali_num ) )
	{
		$isright = "false";
	}

	print STDERR "\r Processed $line_no lines. isright=$isright\n";
	print LOGFILE " Processed $line_no lines. isright=$isright\n";
}


######
# Getting parameters from command
sub get_parameters
{
    if( ( scalar( @_ ) < 2 ) || ( scalar( @_ ) % 2 != 0 ) )
    {
        print STDERR "[USAGE]\n".
                     "            Y1Q4.Extract.pl                 [OPTIONS]\n".
                     "[OPTION]\n".
                     "                -config :  configuration file.\n".
                     "[EXAMPLE]\n".
                     "            perl Y1Q4.Extract.pl -config config-file\n";
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
     if( !exists $param{ "-config" } )
     {
         print STDERR "Error: Please assign the '-config' parameter!\n";
         exit( 1 );
     }
}

