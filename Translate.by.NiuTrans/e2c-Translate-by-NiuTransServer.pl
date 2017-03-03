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
             "#  Translate by NiuTransServer(version 0.3.0)   -- www.nlplab.com  #\n".
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
         my $returnContent = translateByNiuTransServer( $_ );
#          my $returnContent = "服务器正在搭建中，即将开通。";
          if( $returnContent =~ /^$/ )
          {
                    print OUTFILE "\n";
                    print STDERR "\nThe $lineNo sentence was translated false!\n";
                    next;
          }
          print OUTFILE $returnContent."\n";
          print STDERR "\r$lineNo sentences have been translated!";
}
print STDERR "\n";
close( INFILE );
close( OUTFILE );

sub translateByNiuTransServer
{
          my $browser = LWP::UserAgent->new;
          $browser->timeout( 30 );
          my $srcSentence = $_[ 0 ]; 

          $srcSentence =~ s/%/%25/g;
          $srcSentence =~ s/\+/%2B/g;
          $srcSentence =~ s/ /%20/g;
          $srcSentence =~ s/\//%2F/g;
          $srcSentence =~ s/\?/%3F/g;
          $srcSentence =~ s/#/%23/g;
          $srcSentence =~ s/&/%26/g;
          $srcSentence =~ s/=/%3D/g;






  
          my $url = "http://202.118.18.109:8080/NiuTransServer-e2c/translate?input=$srcSentence&type=news&sub=Translate+%3E%3E&output=&hidden=noreset&paras=&from=english";
          my $agent = "Mozilla/4.0 (compatible; MSIE 6.0; Windws NT 5.1)";
          $browser->agent( $agent );

          my $response = $browser->post( $url );
          return "" unless $response->is_success;

          my $responseContent = $response->content;

#         print STDERR $responseContent."\n";
          $responseContent =~ s/[\r\n]//g;
#         print STDERR $responseContent."\n";
#		 exit();

#          print STDERR $responseContent."\n";
		  
          if( $responseContent =~ /<center><font size="5" style="color:red">(.+)<\/font><\/center>/ )
          {
		             print STDERR "\nhere1\n";
#					 print STDERR "$1\n";
		             my $result = $1;
		             $result =~ s/  / /g;
					 $result =~ s/^ +//;
					 $result =~ s/ +$//;
					 $result =~ s/[\r\n]//g;
#					 print STDERR $result."\n";
					 return $result;
		  }
          elsif( $responseContent =~ /<textarea id="output" name="output" rows="13" cols="60" readonly="readonly" style="background-color:#FFF3E5;">(.*)<\/textarea>/ )
          {
#		             print STDERR "\nhere2\n";
#                     $1 =~ s/^ +//;
#					 $1 =~ s/ +$//;
                     my $result = $1;
					 $result =~ s/^ +//;
					 $result =~ s/ +$//;
#                     return $1;
                     return $result;
          }
          else
          {
	             print STDERR "\nhere3\n";

                    return "";
          }
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
