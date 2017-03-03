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
                                       "���ã�\n".
                                       "    ���°汾�ġ�NiuTrans 1.3.0 Beta���������������������http://www.nlplab.com/NiuPlan/NiuTrans.ch.html��\n".
                                       "    ��NiuTrans 1.3.0 Beta��Ϊ�������������о���Ա�ṩ���ܸ���ǿ�����Ӣ������Ԥ����ϵͳ�Լ���������".
                                       "���ͬʱ��NiuTrans�Ŷ�ΪCWMT 2013�����������⼯�ж�����һϵ�����õĽű�����ͬʱ�ṩ��ϸ�ĺ�Ӣ/Ӣ������Σ�����ϵͳ�����ĵ���\n".
                                       "    �����κ��������ʱ��NiuTrans�Ŷ���ϵ��\n".
                                       "        Email: niutrans\@mail.neu.edu.cn\n".
                                       "        weibo: http://weibo.com/niutrans\n".
                                       "    �ǳ���л���NiuTrans�Ĺ�ע��\n".
                                       "\n--\n".
                                       "ף�����ˣ�\n".
                                       "NiuTrans�Ŷ�\n".
                                       "��ҳ: http://www.nlplab.com\n".
                                       "����: niutrans\@mail.neu.edu.cn\n".
                                       "΢��: http://weibo.com/niutrans\n".
                                       "������ѧ��Ȼ���Դ���ʵ����\n".
                                       "�й�����",
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

