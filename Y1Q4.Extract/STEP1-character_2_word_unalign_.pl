#!/usr/bin/perl -w
##################################################################################
#
# NiuTrans - SMT platform
# Copyright (C) 2011, NEU-NLPLab (http://www.nlplab.com/). All rights reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
#
##################################################################################

#######################################
#   version      : 1.1.0
#   Function     : Convert character unalign to word unalign
#   Author       : Qiang Li
#   Email        : liqiangneu@gmail.com
#   Date         : 04/29/2014
#   Last Modified: 
#######################################


use strict;
use Encode;
use utf8;
#use FindBin qw($Bin);

my $logo = "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n".
           "#                                                                  #\n".
           "#   Character 2 word unalign  (version 1.1.0)   --www.nlplab.com   #\n".
           "#                                                                  #\n".
           "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n";

print STDERR $logo;

my %param;
my %option;



getParameter( @ARGV );
character_2_word_unalign();

sub character_2_word_unalign
{
	open( CHARSEGFILE, "<:utf8", $param{ '-charseg' } ) or die "Error: can not open file $param{ '-charseg' }.\n";
	open( WORDSEGFILE, "<:utf8", $param{ '-wordseg' } ) or die "Error: can not open file $param{ '-wordseg' }.\n";
	open( CHARALNFILE, "<:utf8", $param{ '-charaln' } ) or die "Error: can not open file $param{ '-charaln' }.\n";
	open( OUTPUTFILE,  ">:utf8", $param{ '-out' } ) or die "Error: can not open file $param{ '-out' }.\n";
	open( LOGFILE,     ">:utf8", $param{ '-log' } ) or die "Error: can not open file $param{ '-log' }.\n";
	
	my $line_no = 0;
	while( <CHARSEGFILE> )
	{
		++ $line_no;
		s/[\r\n]//g;
		
		my @characters = split /\s+/,$_;
		print LOGFILE "[LINE:$line_no] [RAW   ] [".scalar( @characters)."] ".$_."\n";
		my $char_num = 0;
		my $log_string_tmp;
		foreach my $char_seg ( @characters )
		{
			my @string_vec_tmp = split //,$char_seg;
			$char_num += scalar( @string_vec_tmp );
			foreach my $string_tmp ( @string_vec_tmp )
			{
				$log_string_tmp .= $string_tmp." ";
			}
		}
		$log_string_tmp =~ s/\s+$//g;
		$log_string_tmp =~ s/^\s+//g;
		print LOGFILE "[LINE:$line_no] [MANUAL] [$char_num] $log_string_tmp\n";
		
		my $words_string = <WORDSEGFILE>;
		$words_string =~ s/[\r\n]//g;
		my @words = split /\s+/,$words_string;
		print LOGFILE "[LINE:$line_no] [TOKEN ] [XX] $words_string\n";

		my $character_num_seg_word = 0;
		my $output_string_tmp;
		foreach my $word_tmp ( @words )
		{
			my @string_vec_tmp = split //,$word_tmp;
			$character_num_seg_word += scalar( @string_vec_tmp );
			foreach my $string_tmp ( @string_vec_tmp )
			{
				$output_string_tmp .= $string_tmp." ";
			}
		}
		$output_string_tmp =~ s/\s+$//g;
		$output_string_tmp =~ s/^\s+//g;
		print LOGFILE "[LINE:$line_no] [AUTO  ] [$character_num_seg_word] $output_string_tmp\n";
		
		my $aln_string = <CHARALNFILE>;
		$aln_string =~ s/[\r\n]//g;
		$aln_string =~ s/\s+$//g;
		$aln_string =~ s/^\s+//g;
		my @char_alignments = split /\s+/,$aln_string; 
		
		# print LOGFILE "[LINE_$line_no] [WD ALN ]      ";
		my %deleted_char_pos;
		$log_string_tmp = "[LINE_$line_no] [WD DEL]      ";
		foreach my $char_alignment ( @char_alignments )
		{
			if( $char_alignment =~ /\d+-NULL-\d+/ or $char_alignment =~ /NULL-\d+-\d+/ or $char_alignment =~ /\d+-\d+-\d+/)
			{
				if( $char_alignment =~ /(\d+)-NULL-(\d+)/ )
				{
					if( $2 eq 1 )
					{
#						print LOGFILE "$1 ";
						$log_string_tmp .= $1." ";
						++$deleted_char_pos{ $1 };
					}
				}
			}
			else
			{
				print STDERR "\n  Warning: word alignment error in $line_no line! $char_alignment\n";
			}
		}
		$log_string_tmp =~ s/\s+$//g;
		$log_string_tmp =~ s/^\s+//g;
		print LOGFILE "$log_string_tmp\n";

		
		

		if( $char_num ne scalar( @characters ) ) 
		{
			print LOGFILE "[LINE:$line_no] [SEGMENT]\n";
		}
		
		if( $character_num_seg_word ne $char_num )
		{
			print STDERR "\n  Warning: error in $line_no line!\n";
			print LOGFILE "[LINE:$line_no] [WARNING]\n";
			print OUTPUTFILE "\n";
		}
		else
		{
			if( $char_num eq scalar( @characters ) )
			{
				my $position = 0;
				my $word_position;
				my $output_deleted_word = "";

				foreach my $word_tmp ( @words )
				{
					++$word_position;
					print LOGFILE $word_tmp." ";
					++$position;
					my @string_vec_tmp = split //,$word_tmp;
					print LOGFILE $position." ".( $position + scalar( @string_vec_tmp ) - 1 )."\n";

=pod
					my $log_string_tmp = "[LINE:$line_no] [DELNEW]      ";
                    my $key; 
                    my $value;
                    while( ( $key, $value ) = each %deleted_char_pos )
                    {
#                        print LOGFILE "$key => $value ||| ";
						$log_string_tmp .= $key;
                    }
                    print LOGFILE "$log_string_tmp\n";
=cut
					
					my $current_word_tmp = $word_tmp." |||";
					my $output_deleted_word_tmp = $word_position."-".$word_tmp."-";
					my $tmp_position = $position;
					my $del_num_tmp = 0;
					for( $position..( $position + scalar( @string_vec_tmp ) - 1 ) )
					{	
						if( exists $deleted_char_pos{ $tmp_position } )
						{
#							print LOGFILE "exist:".$tmp_position."\n";
							my $converted_position = $tmp_position - $position + 1;
							$current_word_tmp .= " ".$converted_position;
							++$del_num_tmp;
						}
						++$tmp_position;
					}
					
					if( $current_word_tmp ne $word_tmp." |||" )
					{
						$current_word_tmp .= " ||| ".$del_num_tmp/scalar( @string_vec_tmp );
						print LOGFILE "[LINE:$line_no] [NOSEG] [POS:$word_position] ".$current_word_tmp."\n";
						$output_deleted_word_tmp .= $del_num_tmp/scalar( @string_vec_tmp );
#						print OUTPUTFILE $word_position." ||| ".$current_word_tmp." ";
						$output_deleted_word .= $output_deleted_word_tmp." ";
					}
					$position = $position + scalar( @string_vec_tmp ) - 1;
				}
				if( $output_deleted_word ne "" )
				{
					$output_deleted_word =~ s/\s$//g;
					$output_deleted_word =~ s/^\s//g;
					print OUTPUTFILE "$output_deleted_word\n";
				}
				else
				{
					print OUTPUTFILE "\n";
				}
			}
			else
			{
				my $tmp_raw_position = 0;
				my $tmp_position = 0;
				
				my %deleted_char_pos_new;
				my $log_string_tmp = "[LINE:$line_no] [DELNEW]     ";
				foreach my $character_tmp ( @characters )
				{
					++$tmp_raw_position;
#					++$tmp_position;
					my @chars = split //, $character_tmp;
					foreach my $char_tmp ( @chars )
					{
						++$tmp_position;
						if( exists $deleted_char_pos{ $tmp_raw_position } )
						{
							++ $deleted_char_pos_new{ $tmp_position };
							$log_string_tmp .= " ".$tmp_position;
						}
					}
				}
                print LOGFILE "$log_string_tmp\n";

=pod
				my $log_string_tmp = "[LINE:$line_no] [DELNEW]     ";
				my $key; 
				my $value;
				while( ( $key, $value ) = each %deleted_char_pos_new )
				{
					$log_string_tmp .= " ".$key;
                }
                print LOGFILE "$log_string_tmp\n";
=cut

				my $position = 0;
				my $word_position;
				my $output_deleted_word = "";
				foreach my $word_tmp ( @words )
				{
					++$word_position;
					print LOGFILE $word_tmp." ";
					++$position;
					my @string_vec_tmp = split //,$word_tmp;
					print LOGFILE $position." ".( $position + scalar( @string_vec_tmp ) - 1 )."\n";
=pos
                    my $key; 
                    my $value;
                    while( ( $key, $value ) = each %deleted_char_pos )
                    {
                        print LOGFILE "$key => $value ||| ";
                    }
                    print LOGFILE "\n";
=cut
					my $current_word_tmp = $word_tmp." |||";
					my $output_deleted_word_tmp = $word_position."-".$word_tmp."-";
					my $tmp_position = $position;
					my $del_num_tmp = 0;
					for( $position..( $position + scalar( @string_vec_tmp ) - 1 ) )
					{	
						if( exists $deleted_char_pos_new{ $tmp_position } )
						{
#							print LOGFILE "exist:".$tmp_position."\n";
							my $converted_position = $tmp_position - $position + 1;
							$current_word_tmp .= " ".$converted_position;
							++$del_num_tmp;
						}
						++$tmp_position;
					}
					
					if( $current_word_tmp ne $word_tmp." |||" )
					{						
						$current_word_tmp .= " ||| ".$del_num_tmp/scalar( @string_vec_tmp );
						$output_deleted_word_tmp .= $del_num_tmp/scalar( @string_vec_tmp );
						print LOGFILE "[LINE:$line_no] [SEG  ] [POS:$word_position]".$current_word_tmp."\n";
#						print OUTPUTFILE $word_position." ||| ".$current_word_tmp." ";
#						print $output_deleted_word_tmp." ";
						$output_deleted_word .= $output_deleted_word_tmp." ";
					}
					$position = $position + scalar( @string_vec_tmp ) - 1;
				}
				if( $output_deleted_word ne "" )
				{
					$output_deleted_word =~ s/\s$//g;
					$output_deleted_word =~ s/^\s//g;
					print OUTPUTFILE "$output_deleted_word\n";
				}
				else
				{
					print OUTPUTFILE "\n";
				}
			}
		}
		
		
		if( $line_no % 1000 == 0 )
		{
			print STDERR "\r  Processed $line_no lines.";
		}
	}
	print STDERR "\r  Processed $line_no lines.\n";
	
	close( CHARSEGFILE);
	close( WORDSEGFILE );
	close( CHARALNFILE );
	close( OUTPUTFILE );
	close( LOGFILE );
}

sub getParameter
{
    if( ( scalar( @_ ) < 4 ) || ( scalar( @_ ) % 2 != 0 ) )
    {
        print STDERR "[USAGE]\n".
                     "         Error.Classifier.pl                 [OPTIONS]\n".
                     "[OPTION]\n".
                     "          -charseg  :  Character segmented file.\n".
                     "          -wordseg  :  Word segmented file.\n".
                     "          -charaln  :  Character alignment file.\n".
                     "          -out      :  Classified Results.\n".
                     "          -log      :  Log File.\n".
                     "[EXAMPLE]\n".
                     "         perl Error.Classifier.pl       [-charseg  FILE]\n".
                     "                                        [-wordseg  FILE]\n".
                     "                                        [-charaln  FILE]\n".
                     "                                        [-out      FILE]\n".
                     "                                        [-log      FILE]\n";
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
         
    if( !exists $param{ "-charseg" } )
    {
        print STDERR "Error: please assign '-charseg'!\n";
        exit( 1 );
    }
    if( !exists $param{ "-wordseg" } )
    {
        print STDERR "Error: please assign '-wordseg'!\n";
        exit( 1 );
    }
          
    if( !exists $param{ "-charaln" } )
    {
        print STDERR "Error: please assign '-charaln'!\n";
        exit( 1 );
    }
    if( !exists $param{ "-out" } )
    {
        print STDERR "Error: please assign '-out'!\n";
        exit( 1 );
    }
    if( !exists $param{ "-log" } )
    {
        print STDERR "Error: please assign '-log'!\n";
        exit( 1 );
    }
          
}


######
# Reading configuration file
sub read_config_file
{
    print STDERR "Error: Config file does not exist!\n" if( scalar( @_ ) != 1 );
    $_[0] =~ s/\\/\//g;
    open( CONFIGFILE, "<".$_[0] ) or die "\nError: Can not read file $_[0] \n";
    print STDERR "Starting reading configuration from $param{ \"-config\" } file...\n";
    my $configFlag = 0;
    my $appFlag = 0;
    my $lineNo = 0;
    while( <CONFIGFILE> )
    {
        s/[\r\n]//g;
        next if /^( |\t)*$/;
        if( /param(?: |\t)*=(?: |\t)*"([\w\-]*)"(?: |\t)*value="([\w\/\-. :]*)"(?: |\t)*/ )
        {
            ++$lineNo;
            $option{ $1 } = $2;
            print STDERR "\r  Processed $lineNo lines.";
        }
    }
    close( CONFIGFILE ); 
    print STDERR "\r  Processed $lineNo lines.\n";
}




