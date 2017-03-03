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
#   Function     : Split Paragraph
#   Author       : Qiang Li
#   Email        : liqiangneu@gmail.com
#   Date         : 08/07/2012
#   Last Modified: 
#######################################


use strict;
#use Encode;
#use utf8;

my %param;

getParameter( @ARGV );

open( INFILE, "<", $param{ "-in" }  ) or die "Error: Can not open file $param{ \"-in\" }.\n";
open( OUTFILE,">", $param{ "-out" } ) or die "Error: Can not open file $param{ \"-out\" }.\n";

my $lineNo = 0;
while( <INFILE> )
{
          ++$lineNo;
          s/[\r\n]//g;
		  s/^ +//g;
		  s/ +$//g;
		  s/^\t+//g;
		  s/\t+$//g;
		  s/。/。\n/g;
		  s/！/！\n/g;
#          my @sentences = split /。/,$_;
#		  foreach my $word ( @sentences )
#		  {
#		            print OUTFILE $word."\n";
#		  }
		  s/\n+$//g;
		  
		  if( $_ ne "" )
		  {
			  print OUTFILE $_."\n\n";
		  }
#
		  else
		  {
		      print OUTFILE "\n";
		  }
#		  
		  
		  
		  print STDERR "\r    Processed $lineNo lines.";
		
}
print STDERR "\r    Processed $lineNo lines.\n";

close( INFILE );
close( OUTFILE );

sub getParameter
{
          if( ( scalar( @_ ) < 2 ) || ( scalar( @_ ) % 2 != 0 ) )
          {
                    print STDERR "[USAGE]\n".
                                 "     SplitParagraph.pl                 [OPTIONS]\n".
                                 "[OPTION]\n".
                                 "            -in  :  Inputted File.\n".
                                 "            -out :  Outputted File.\n".
                                 "[EXAMPLE]\n".
                                 "     perl SplitParagraph.pl            [-in  FILE]\n".
                                 "                                       [-out FILE]\n";
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

          
          if( !exists $param{ "-in" } )
          {
                    print STDERR "Error: please assign \"-in\"!\n";
                    exit( 1 );
          }
          elsif( !( -e $param{ "-in" } ) )
          {
                    print STDERR "Error: $param{ \"-in\" } does not exist!\n";
                    exit( 1 );
          }
                    
          if( !exists $param{ "-out" } )
          {
                    print STDERR "Error: please assign \"-out\"!\n";
                    exit( 1 );
          }
}

sub ssystem
{
          print STDERR "Running: @_\n";
          system( @_ );
          if( $? == -1 )
          {
                    print STDERR "Error: Failed to execute: @_\n  $!\n";
                    exit( 1 );
          }
          elsif( $? & 127 )
          {
                    printf STDERR "Error: Execution of: @_\n   die with signal %d, %s coredump\n",
                    ($? & 127 ), ( $? & 128 ) ? 'with' : 'without';
                    exit( 1 );
          }
          else
          {
                    my $exitcode = $? >> 8;
                    print STDERR "Exit code: $exitcode\n" if $exitcode;
                    return ! $exitcode;
          }         
}

