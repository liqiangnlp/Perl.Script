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
#   Function     : NiuTrans-lm.segmentation.gene.stopwords.4.pl
#   Author       : Qiang Li
#   Email        : liqiangneu@gmail.com
#   Date         : 09/12/2012
#   Last Modified: 
#######################################


use strict;
use Encode;
use utf8;

my $logo =   "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n".
             "#                                                                  #\n".
             "#  NiuTrans lm.segmentation.gene.stopwords.4     --www.nlplab.com  #\n".
             "#                                                                  #\n".
             "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n";

print STDERR $logo;

my %param;

getParameter( @ARGV );

my $lineNo = 0;

my %dict4;
open( DICT4, "<", $param{ "-dict4" } ) or die "Error: can not open file $param{ \"-dict4\" }.\n";
print STDERR "Starting Loading $param{ \"-dict4\" }...\n";
while( <DICT4> )
{
    ++$lineNo;
	s/[\r\n]//g;
	++$dict4{ $_ };
	print STDERR "\r    Processed $lineNo lines." if( $lineNo % 1000 == 0 );
}
print STDERR "\r    Processed $lineNo lines.\n";
close( DICT4 );

my %dict3;
$lineNo = 0;
open( DICT3, "<", $param{ "-dict3" } ) or die "Error: can not open file $param{ \"-dict3\" }.\n";
print STDERR "Starting Loading $param{ \"-dict3\" }...\n";
while( <DICT3> )
{
    ++$lineNo;
	s/[\r\n]//g;
	++$dict3{ $_ };
	print STDERR "\r    Processed $lineNo lines." if( $lineNo % 1000 == 0 );
}
print STDERR "\r    Processed $lineNo lines.\n";
close( DICT3 );

my %dict2;
$lineNo = 0;
print STDERR "Starting Loading $param{ \"-dict2\" }...\n";
open( DICT2, "<", $param{ "-dict2" } ) or die "Error: can not open file $param{ \"-dict2\" }.\n";
while( <DICT2> )
{
    ++$lineNo;
	s/[\r\n]//g;
	++$dict2{ $_ };
	print STDERR "\r    Processed $lineNo lines." if( $lineNo % 1000 == 0 );
}
print STDERR "\r    Processed $lineNo lines.\n";
close( DICT2 );

my %dict1;
$lineNo = 0;
print STDERR "Starting Loading $param{ \"-dict1\" }...\n";
open( DICT1, "<", $param{ "-dict1" } ) or die "Error: can not open file $param{ \"-dict1\" }.\n";
while( <DICT1> )
{
    ++$lineNo;
	s/[\r\n]//g;
	++$dict1{ $_ };
	print STDERR "\r    Processed $lineNo lines." if( $lineNo % 1000 == 0 );
}
print STDERR "\r    Processed $lineNo lines.\n";
close( DICT1 );


open( REDICT4, "<", $param{ "-dict4" } ) or die "Error: can not open file $param{ \"-dict\" }.\n";
open( OUTPUT,  ">", $param{ "-output" } ) or die "Error: can not open file $param{ \"-output\" }.\n";
open( OUTPUTCON, ">", $param{ "-output" }.".conflict" ) or die "Error: can not open file $param{ \"-output\" }.conflict.\n";
open( RESERVE, ">", $param{ "-reserve" } ) or die "Error: can not open file $param{ \"-reserve\" }.\n";
$lineNo = 0;
my $reserveNum = 0;
my $stopwordsNum = 0;
my $conflictNum = 0;
while( <REDICT4> )
{
    ++$lineNo;
	s/[\r\n]//g;
	
	my $canBeSplit2AND2 = 0;
	my $canBeSplit1AND3 = 0;
	my $canBeSplit3AND1 = 0;
	my $conflict = 0;
	
	my $prev = "";
	my $last = "";
	
	if( /^(....)(....)$/ )
	{
        if( exists $dict2{ $1 } and exists $dict2{ $2 } )
		{
		    ++$canBeSplit2AND2;
		}
	}
	
	if( ( $canBeSplit2AND2 eq 1 ) and /^(..)(......)$/ )
	{
	    if( exists $dict1{ $1 } and exists $dict3{ $2 } )
		{
		    $prev = $1;
			$last = $2;
		    ++$canBeSplit1AND3;
		}
	}
	if( ( $canBeSplit2AND2 eq 1 ) and /^(......)(..)$/ )
	{
	    if( exists $dict3{ $1 } and exists $dict1{ $2 } )
		{
		    $prev = $1;
			$last = $2;
		    ++$canBeSplit3AND1;
		}
	}
	
	if( ( $canBeSplit2AND2 eq 1 ) and ( $canBeSplit1AND3 + $canBeSplit3AND1 >= 1 ) )
	{
	    ++$conflict;
	}
	
	if( $conflict eq 1 )
	{
	    ++$conflictNum;
	    print OUTPUTCON $_."\t"."$prev $last"."\n";
	}
	elsif( $canBeSplit2AND2 eq 1 )
	{
	    ++$stopwordsNum;
	    print OUTPUT $_."\n";
	}
	else
	{
	    ++$reserveNum;
	    print RESERVE $_."\n";
	}
	print STDERR "\r    Processed $lineNo lines. [RES=$reserveNum STOPWORD=$stopwordsNum CONFLICT=$conflictNum]" if( $lineNo % 1000 == 0 );
}
print STDERR "\r    Processed $lineNo lines. [RES=$reserveNum STOPWORD=$stopwordsNum CONFLICT=$conflictNum]\n";
close( REDICT4 );
close( OUTPUT );
close( OUTPUTCON );
close( RESERVE );

sub getParameter
{
          if( ( scalar( @_ ) < 4 ) || ( scalar( @_ ) % 2 != 0 ) )
          {
                    print STDERR "[USAGE]\n".
                                 "         NiuTrans-lm.segmentation.gene.stopwords.4.pl [OPTIONS]\n".
                                 "[OPTION]\n".
                                 "             -dict4    :  Dict with length 4 word.\n".
                                 "             -dict3    :  Dict with length 3 word.\n".
                                 "             -dict2    :  Dict with length 2 word.\n".
                                 "             -dict1    :  Dict with length 1 word.\n".
                                 "             -output   :  Outputted File.\n".
								 "             -reserve  :  Reserved File.\n".
                                 "[EXAMPLE]\n".
                                 "     perl NiuTrans-lm.segmentation.gene.stopwords.4.pl [-output  FILE]\n".
                                 "                                                       [-reserve FILE]\n".
                                 "                                                       [-dict4   FILE]\n".
                                 "                                                       [-dict3   FILE]\n".
                                 "                                                       [-dict2   FILE]\n".
                                 "                                                       [-dict1   FILE]\n";
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

          if( !exists $param{ "-dict4" } )
          {
                    print STDERR "Error: please assign \"-dict4\"!\n";
                    exit( 1 );
          }
          if( !exists $param{ "-dict3" } )
          {
                    print STDERR "Error: please assign \"-dict3\"!\n";
                    exit( 1 );
          }
          if( !exists $param{ "-dict2" } )
          {
                    print STDERR "Error: please assign \"-dict2\"!\n";
                    exit( 1 );
          }
          if( !exists $param{ "-dict1" } )
          {
                    print STDERR "Error: please assign \"-dict1\"!\n";
                    exit( 1 );
          }

          if( !exists $param{ "-output" } )
          {
                    print STDERR "Error: please assign \"-output\"!\n";
                    exit( 1 );
          }
          if( !exists $param{ "-reserve" } )
          {
                    print STDERR "Error: please assign \"-reserve\"!\n";
                    exit( 1 );
          }
}
