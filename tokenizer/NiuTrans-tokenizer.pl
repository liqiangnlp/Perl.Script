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
#   Function     : tokenizer
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
             "#      NiuTrans  tokenizer  (version 1.1.0)  --www.nlplab.com      #\n".
             "#                                                                  #\n".
             "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n";

print STDERR $logo;

my %param;

getParameter( @ARGV );
tokenize();

sub tokenize
{
          print STDERR "Start tokenize...\n";
          open( INFILE, "<", $param{ "-in"  } ) or die "Error: can not open file $param{ \"-in\" }.\n";
          open( OUTPUT, ">", $param{ "-out" } ) or die "Error: can not open file $param{ \"-out\" }.\n";



          close( INFILE );
          close( OUTFILE );
}

sub getParameter
{
          if( ( scalar( @_ ) < 4 ) || ( scalar( @_ ) % 2 != 0 ) )
          {
                    print STDERR "[USAGE]\n".
                                 "         NiuTrans-tokenizer.pl                 [OPTIONS]\n".
                                 "[OPTION]\n".
                                 "          -in     :  Input  File.\n".
                                 "          -out    :  Output File.\n".
                                 "[EXAMPLE]\n".
                                 "         perl NiuTrans-tokenizer.pl            [-in  FILE]\n".
                                 "                                               [-out FILE]\n";
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
          
          if( !exists $param{ "-out" } )
          {
                    print STDERR "Error: please assign \"-out\"!\n";
                    exit( 1 );
          }
          
}
