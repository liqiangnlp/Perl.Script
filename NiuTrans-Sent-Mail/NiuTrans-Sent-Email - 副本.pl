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
#   version          : 1.0
#   Function         : Sent Email to Maillist
#   Author           : Qiang Li
#   Email            : liqiangneu@gmail.com
#   Date             : 05/30/2012
#   last Modified by : QiangLi in 2012-05-30.
#############################################

##################################################################################
#   INSTALL:
#       STEP1: Download Mail-Sender-0.8.16.tar.gz or higher from 
#              "http://search.cpan.org/~jenda/Mail-Sender-0.8.16/Sender.pm".
#       STEP2: Execute "Makefile.PL" in Mail-Sender-0.8.16.
#       STEP3: Copy "Mail/Sender.pm" which is in Mail-Sender-0.8.16 to @INC
#              (for example, "D:/Program Files (x86)/Perl/lib/").
#   DATA FORMAT:
#       INPUT FILE: 
#              "Email ||| num" per line.
#   USAGE:
#       perl NiuTrans-Sent-Email.pl MAILLIST LOG
##################################################################################

use strict;
use warnings;
use Mail::Sender;

if( scalar( @ARGV ) != 2 )
{
    print STDERR "[USAGE]\n".
                 "       perl NiuTrans-Sent-Email.pl MAILLIST LOG\n";
    exit( 1 );
}

open( MAILLIST, "<", $ARGV[ 0 ] ) or die "Error: can not open file $ARGV[0]\n";
open( LOG, ">", $ARGV[ 1 ] ) or die "Error: can not open file $ARGV[1]\n";

my $sender = new Mail::Sender{
                               smtp => 'smtp.neu.edu.cn',
                               from => 'niutrans@mail.neu.edu.cn',
                               on_errors => 'die',
                             } or die "Can't create the Mail::Sender object: $Mail::Sender::Error\n";



my $mailNo = 0;
my $mailSentFailure = 0;
my $mailSentSuccess = 0;
while( <MAILLIST>)
{
    ++$mailNo;
    s/[\r\n]//g;
    if( $_ =~ /(.*) \|\|\| (.*)/)
    {
        my $to = $1;
        if($sender->MailMsg( {
                                to => "$to",
                                subject => 'NiuTrans Version 1.3.0 Beta Released',
                                msg => "Hi\n".
                                       "    The latest version of NiuTrans (Version 1.3.0 Beta) is now available".
                                       " from http://www.nlplab.com/NiuPlan/NiuTrans.html.\n".
                                       "    The updates in NiuTrans 1.3.0 Beta".
                                       " include a new pipeline of data proprecessing, bug fixes for NiuTrans Decoder and several scripts developed for CWMT 2013.\n".
                                       "    Please feel free to contact us if you have any questions.\n".
                                       "        email: niutrans\@mail.neu.edu.cn\n".
                                       "        weibo: http://weibo.com/niutrans\n".
                                       "    Thank you for your interest in NiuTrans!\n".
                                       "    Enjoy!\n".
                                       "\n--\n".
                                       "Best regards\n".
                                       "NiuTrans Team\n".
                                       "Homepage: http://www.nlplab.com\n".
                                       "Email: niutrans\@mail.neu.edu.cn\n".
                                       "weibo: http://weibo.com/niutrans\n".
                                       "Natural Language Processing Laboratory\n".
                                       "Northeastern University, Shenyang, P.R.China\n".
                                       "\n\n----------------------------------------\n\n".
                                       "您好！\n".
                                       "    最新版本的“NiuTrans 1.3.0 Beta”可以下载啦！点击访问http://www.nlplab.com/NiuPlan/NiuTrans.ch.html。\n".
                                       "    “NiuTrans 1.3.0 Beta”为机器翻译的相关研究人员提供功能更加强大的中英文数据预处理系统以及解码器。".
                                       "与此同时，NiuTrans团队为CWMT 2013机器翻译评测集中定制了一系列有用的脚本程序，同时提供详细的汉英/英汉（层次）短语系统构建文档。\n".
                                       "    如有任何问题可随时与NiuTrans团队联系：\n".
                                       "        Email: niutrans\@mail.neu.edu.cn\n".
                                       "        weibo: http://weibo.com/niutrans\n".
                                       "    非常感谢你对NiuTrans的关注！\n".
                                       "\n--\n".
                                       "祝您好运！\n".
                                       "NiuTrans团队\n".
                                       "主页: http://www.nlplab.com\n".
                                       "邮箱: niutrans\@mail.neu.edu.cn\n".
                                       "微博: http://weibo.com/niutrans\n".
                                       "东北大学自然语言处理实验室\n".
                                       "中国沈阳",
                                auth => 'LOGIN',
                                authid => 'niutrans',
                                authpwd => 'neunlpzjb',
                              }
                             ) < 0 ){
                                      ++$mailSentFailure;
                                      print STDERR "Can not sent to $_, $Mail::Sender::Error\n";
                                      next;
                                    }   
        ++$mailSentSuccess;
        print STDERR "Success sent mail to $to\n";
        print LOG "$to\n";
    }
    else
    {
        ++$mailSentFailure;
        print STDERR "Format of MAILLIST is wrong!\n";
        next;
    }
}
close( MAILLIST );
close( LOG );

print STDERR"[TOTAL:$mailNo SUCCESS:$mailSentSuccess FAILURE:$mailSentFailure]\n";

