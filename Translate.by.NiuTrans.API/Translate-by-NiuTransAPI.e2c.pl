#!/usr/bin/perl

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

#############################################
#   version          : 3.0
#   Function         : translation by NiuTransServer
#   Author           : Qiang Li
#   Email            : liqiangneu@gmail.com
#   Date             : 01/10/2012
#   last Modified by : NULL
#############################################

use strict;
use Encode;
use HTTP::Request;
use HTTP::Response;
use HTTP::Headers;
use HTTP::Cookies;
use HTTP::Request::Common qw(POST);
use LWP;
use LWP::UserAgent;
use URI::URL;
use URI::Escape;
use HTML::LinkExtor;

my $logo =   "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n".
             "#                                                                  #\n".
             "#  Translate by NiuTransAPI(version 0.3.0)   -- www.nlplab.com  #\n".
             "#                                                                  #\n".
             "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n";

print STDERR $logo;

my %param;
getParameter( @ARGV );
open( INFILE, "<", $param{ "-in" } ) or die "Error: can not open file $param{ \"-in\" }\n";
open( OUTFILE, ">", $param{ "-out" } ) or die "Error: can not open file $param{ \"-out\" }\n";
my $lineNo = 0;
while( <INFILE> )
{
          ++$lineNo;
          s/[\r\n]//g;
          if( $_ =~ /^$/ )
          {
                    print OUTFILE "\n";
                    print STDERR "\nThe $lineNo line is empty!\n";
                    next;
          }
          my $transinput = $_;
          
          my @words = split / +/, $transinput;
          my $pos = 0;
          my $errorFlag = 0;
          for( $pos = 0; $pos < scalar( @words ); ++$pos )
          {
                    if( length( $words[ $pos ] ) > 100 )
                    {
                               $errorFlag = 1;
                               last;
                    }
          }
          
          if( $errorFlag == 1 )
          {
                    print OUTFILE "[SENTENCE$lineNo]\n";
                    print OUTFILE "The inputted sentence is error!\n";
                    next;
          }
          
          my $returnContent = translateByNiuTransServer( $transinput, 0 );

          print OUTFILE "[SENTENCE$lineNo]\n".$returnContent."\n";
          print STDERR "\r$lineNo sentences have been translated!     ";
}
print STDERR "\n";
close( INFILE );
close( OUTFILE );

sub translateByNiuTransServer
{
          my $browser = LWP::UserAgent->new;
          $browser->timeout( $_[ 1 ] );
          my $srcSentence = $_[ 0 ];

          $srcSentence =~ s/%/%25/g;
          $srcSentence =~ s/\+/%2B/g;
          $srcSentence =~ s/ /%20/g;
          $srcSentence =~ s/\//%2F/g;
          $srcSentence =~ s/\?/%3F/g;
          $srcSentence =~ s/#/%23/g;
          $srcSentence =~ s/&/%26/g;
          $srcSentence =~ s/=/%3D/g; 
  
          my $url = "http://192.168.1.186:8383/mt/translateE2C?from=english&to=chinese&src_text=$srcSentence";
          my $agent = "Mozilla/4.0 (compatible; MSIE 6.0; Windws NT 5.1)";
          $browser->agent( $agent );

          my $response = $browser->post( $url );
          return "" unless $response->is_success;

          my $responseContent = $response->content;

          $responseContent =~ s/[\r\n]//g;
          

          return $responseContent;
}

sub getParameter
{
          if( ( scalar( @_ ) < 4 ) || ( scalar( @_ ) % 2 != 0 ) )
          {
                    print STDERR "[USAGE]         :\n".
                                 "    NiuTrans-translate-by-google.pl           [OPTIONS]\n".
                                 "[OPTIONS]       :\n".
                                 "      -in       :  Input  File.\n".
                                 "      -out      :  Output File.\n".
                                 "      -srcLang  :  Source Language.           [optional]\n".
                                 "                   Default is \"zh-CN\".\n".
                                 "      -tgtLang  :  Target Language.           [optional]\n".
                                 "                   Default is \"en\".\n".
                                 "[NOTE]          :\n".
                                 "    For the \"-srcLang\" and \"-tgtLang\", you can choose\n".
                                 "      zh-CN     :  Simplified Chinese\n".
                                 "      en        :  English\n".
                                 "      ja        :  Japanese\n".
                                 "[EXAMPLE]       :\n".
                                 "    perl NiuTrans-translate-by-google.pl -in ifile -out ofile\n";
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

          if( !exists $param{ "-srcLang" } )
          {
                    $param{ "-srcLang" } = "zh-CN";
          }
          if( !exists $param{ "-tgtLang" } )
          {
                     $param{ "-tgtLang" } = "en";
          }
}
