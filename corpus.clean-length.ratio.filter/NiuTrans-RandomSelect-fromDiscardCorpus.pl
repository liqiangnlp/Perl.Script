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
#   Function     : RandomSelect-fromDevAndTransRes
#   Author       : Qiang Li
#   Email        : liqiangneu@gmail.com
#   Date         : 08/06/2012
#   Last Modified: 
#######################################


use strict;
use Encode;
use utf8;

my $logo =   "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n".
             "#                                                                  #\n".
             "#    NiuTrans Random Select (version 1.1.0)    --www.nlplab.com    #\n".
             "#                                                                  #\n".
             "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n";

print STDERR $logo;

my %param;

getParameter( @ARGV );

print STDERR "srcdiscard=$param{ \"-srcdiscard\" }\n".
             "tgtdiscard=$param{ \"-tgtdiscard\" }\n";
			 
my $numOfSrcDiscard = 0;
open( SRCDISCARD, "<", $param{ "-srcdiscard" } ) or die "Error: can not open file $param{ \"-srcdiscard\" }.\n";
while( <SRCDISCARD> )
{
    ++$numOfSrcDiscard;
}
print STDERR "numOfSrcDiscard=$numOfSrcDiscard\n";
close( SRCDISCARD );

my $lineNo = 0;
my $outputNo = 0;
my $randomNo = 0;
my $lineOfSrcDiscard;
open( SRCDISCARD, "<", $param{ "-srcdiscard" } ) or die "Error: can not open file $param{ \"-srcdiscard\" }.\n";
open( TGTDISCARD, "<", $param{ "-tgtdiscard" } ) or die "Error: can not open file $param{ \"-tgtdiscard\" }.\n";
open( OUTPUTSRCRANDOM, ">", $param{ "-outSrcRandom" } ) or die "Error: can not open file $param{ \"-outSrcRandom\" }.\n";
open( OUTPUTTGTRANDOM, ">", $param{ "-outTgtRandom" } ) or die "Error: can not open file $param{ \"-outTgtRandom\" }.\n";
while( $lineOfSrcDiscard = <SRCDISCARD> )
{
	++$lineNo;
	$lineOfSrcDiscard =~ s/[\r\n]//g;
	$randomNo = int( rand( $numOfSrcDiscard ) );
	
	if( $outputNo >= $param{ "-selnum" } )
	{
	    last;
	}
	
	if( $randomNo < $param{ "-selnum" } )
	{
		my $lineOfTgtDiscard = <TGTDISCARD>;
        $lineOfTgtDiscard =~ s/[\r\n]//g;
        print OUTPUTSRCRANDOM "$lineOfSrcDiscard\n";
		print OUTPUTTGTRANDOM "$lineOfTgtDiscard\n";
     	++$outputNo;
	}
	else
	{
	    <TGTDISCARD>;
	    next;
	}
	print STDERR "\rOutputNo=$outputNo lineNo=$lineNo randomNo=$randomNo";
}
print STDERR "\rOutputNo=$outputNo lineNo=$lineNo randomNo=$randomNo\n";
close( SRCDISCARD );
close( TGTDISCARD );
close( OUTPUTSRCRANDOM );
close( OUTPUTTGTRANDOM );

sub getParameter
{
          if( ( scalar( @_ ) < 4 ) || ( scalar( @_ ) % 2 != 0 ) )
          {
                    print STDERR "[USAGE]\n".
                                 "     NiuTrans-RandomSelect-fromDiscardCorpus.pl      [OPTIONS]\n".
                                 "[OPTION]\n".
                                 "          -srcdiscard :  Input Src Discard File.\n".
                                 "          -tgtdiscard :  Input Tgt Discard File.\n".
                                 "              -selnum :  The Number of Output Items.\n".
								 "        -outSrcRandom :  Output Src Random Select.\n".
								 "        -outTgtRandom :  Output Tgt Random Select.\n".
                                 "[EXAMPLE]\n".
                                 "     perl NiuTrans-RandomSelect-fromDiscardCorpus.pl [-srcdiscard   FILE]\n".
                                 "                                                     [-tgtdiscard   FILE]\n".
								 "                                                     [-outSrcRandom FILE]\n".
								 "                                                     [-outTgtRandom FILE]\n".
								 "                                                     [-selnum       20  ]\n";
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
          
          if( !exists $param{ "-srcdiscard" } )
          {
                    print STDERR "Error: please assign \"-srcdiscard\"!\n";
                    exit( 1 );
          }
          if( !exists $param{ "-tgtdiscard" } )
          {
                    print STDERR "Error: please assign \"-tgtdiscard\"!\n";
                    exit( 1 );
          }
		  
		  if( !exists $param{ "-selnum" } )
          {
		            print STDERR "Error: please assign \"-selnum\"!\n";
					exit( 1 );
          }
		  
		  if( !exists $param{ "-outSrcRandom" } )
          {
		            print STDERR "Error: please assign \"-outSrcRandom\"!\n";
					exit( 1 );
          }
		  
		  if( !exists $param{ "-outTgtRandom" } )
          {
		            print STDERR "Error: please assign \"-outTgtRandom\"!\n";
					exit( 1 );
          }

}
