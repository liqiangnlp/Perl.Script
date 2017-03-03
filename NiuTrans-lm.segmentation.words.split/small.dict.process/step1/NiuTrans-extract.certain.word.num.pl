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
#   Function     : NiuTrans-clear.illegal.char
#   Author       : Qiang Li
#   Email        : liqiangneu@gmail.com
#   Date         : 08/21/2012
#   Last Modified: 
#######################################


use strict;
use Encode;
use utf8;

my $logo =   "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n".
             "#                                                                  #\n".
             "#  NiuTrans extract certain word num             --www.nlplab.com  #\n".
             "#                                                                  #\n".
             "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n";

print STDERR $logo;

my %param;

getParameter( @ARGV );

open( INPUTFILE,  "<", $param{ "-input" }  ) or die "Error: can not read file $param{ \"-input\" }.\n";
open( OUTPUTFILE, ">", $param{ "-output" }.".".$param{ "-wdnum" } ) or die "Error: can not read file $param{ \"-output\" }.$param{ \"-wdnum\" }.\n";

my $lineNo = 0;
my $findNo = 0;
while( <INPUTFILE> )
{
    ++$lineNo;
	s/[\r\n]//g;
	
	if( length( $_ ) == $param{ "-wdnum" }*2 )
	{
		++$findNo;
		print OUTPUTFILE $_."\n";
	}
	
	print STDERR "\r    Processed $lineNo lines." if( $lineNo % 10000 == 0 );
}
print STDERR "\r    Processed $lineNo lines.\n";
close( INPUTFILE );
close( OUTPUTFILE );

sub getParameter
{
          if( ( scalar( @_ ) < 4 ) || ( scalar( @_ ) % 2 != 0 ) )
          {
                    print STDERR "[USAGE]\n".
                                 "         NiuTrans-lm.segmentation.words.split.pl [OPTIONS]\n".
                                 "[OPTION]\n".
                                 "             -input    :  Inputted File.\n".
                                 "             -output   :  Outputted File.\n".
                                 "             -wdnum    :  Word Number Restrict.\n".
								 "                            Default value is '4'.\n".
                                 "[EXAMPLE]\n".
                                 "     perl NiuTrans-lm.segmentation.words.split.pl [-input  FILE]\n".
                                 "                                                  [-output FILE]\n".
                                 "                                                  [-wdnum  FILE]\n";
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
          
          if( !exists $param{ "-input" } )
          {
                    print STDERR "Error: please assign \"-input\"!\n";
                    exit( 1 );
          }
          
          if( !exists $param{ "-output" } )
          {
                    print STDERR "Error: please assign \"-output\"!\n";
                    exit( 1 );
          }

          if( !exists $param{ "-wdnum" } )
          {
                    $param{ "-wdnum" } = 4;
          }
		  
}
