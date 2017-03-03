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
#   Function     : Error Classifier
#   Author       : Qiang Li
#   Email        : liqiangneu@gmail.com
#   Date         : 04/24/2014
#   Last Modified: 
#######################################


use strict;
use Encode;
use utf8;
#use FindBin qw($Bin);

my $logo = "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n".
           "#                                                                  #\n".
           "#      Error Classifier  (version 1.1.0)     --www.nlplab.com      #\n".
           "#                                                                  #\n".
           "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n";

print STDERR $logo;

my %param;
my %option;

my %deleted_words;
my %phrase_table;

getParameter( @ARGV );
read_config_file( $param{ '-config' } );

load_phrase_table();
error_classifier();

sub load_phrase_table
{
    print STDERR "Loading phrase table...\n";
    
    open( INPUTPHRASETAB, "<", $param{ '-pt' } ) or die "Error: can not open file $param{ '-pt' }.\n";
    
    my $line_no = 0;
    while( <INPUTPHRASETAB> )
    {
        ++$line_no;
        s/[\r\n]//g;
        my @domains = split / \|\|\| /, $_;
        $domains[ 0 ] =~ s/^\s+//g;
        $domains[ 0 ] =~ s/\s+$//g;
        $domains[ 1 ] =~ s/^\s+//g;
        $domains[ 1 ] =~ s/\s+$//g;
        $domains[ 4 ] =~ s/^\s+//g;
        $domains[ 4 ] =~ s/\s+$//g;
        $phrase_table{ $domains[ 0 ].$domains[ 1 ] } = $domains[ 4 ];
        
        if( $line_no % 10000 == 0 )
        {
            print STDERR "\r  Processed $line_no lines.";
        }
    }
    print STDERR "\r  Processed $line_no lines. PHRASE=".(keys %phrase_table)."\n";
    
    close( INPUTPHRASETAB );
}

sub error_classifier
{
    my $trans_null = 0;
    my $trans_inter_null = 0;
    my $trans_boundary_null = 0;
    my $trans_error = 0;
    my $error_number = 0;
    my $total_word_deletion_error = 0;

    open( INPUTMARKDATA, "<", $param{ '-markdata' } ) or die "Error: can not open file $param{ '-markdata' }.\n";
    open( OUTPUTMARKDATARAW, ">", $param{ '-markdata' }.".raw" ) or die "Error: can not open file $param{ '-markdata' }.raw.\n";
    open( OUTPUTMARKDATA, ">", $param{ '-markdata' }.".preprocess" ) or die "Error: can not open file $param{ '-markdata' }.preprocess.\n";
    open( INPUTDECLOG, "<", $param{ "-declog" } ) or die "Error: can not open file $param{ '-declog' }.\n";
    open( LOGFILE, ">", $param{ "-log" } ) or die "Error: can not open file $param{ '-log' }.\n";
    
    
    my $line_no = 0;
    my $sentence_no = 0;
    print STDERR "Starting loading manually marked data...\n";
    while( <INPUTMARKDATA> )
    {
        ++$line_no;
        s/[\r\n]//g;
        if( /^##\d+/ )
        {
#            print STDERR $_."\n";
            ++$sentence_no;
            my @words;
            my %words_label_and_new;
            my @deleted_labels;
            my %deleted_labels_new;
            my $last_label = 0;
            while( my $line_string = <INPUTMARKDATA> )
            {
                $line_string =~ s/[\r\n]//g;
                
                if( $line_string =~ /$option{ 'token-src' }:(.*)/ )
                {
                    my $sentence = $1;
                    $sentence =~ s/\s+$//g;
                    $sentence =~ s/^\s+//g;
                    print OUTPUTMARKDATARAW $sentence."\n";
                    @words = split /\s+/, $sentence;
                    
                    my $current_pos = 0;
                    my $new_pos = 0;
                    foreach my $word ( @words )
                    {
                        ++$current_pos;
                        ++$new_pos;
                        if( $word =~ /\$number/ or $word =~ /\$date/ or $word =~ /\$time/ )
                        {
                            ++$new_pos;
#                            print STDERR "$word\n";
                            $words_label_and_new{ $new_pos } = $current_pos;
                        }
                        else
                        {
                            $words_label_and_new{ $new_pos } = $current_pos;
                        }
                    }
                    
=pod
                    my $key; 
                    my $value;
                    while( ( $key, $value ) = each %words_label_and_new )
                    {
                        print STDERR "$key => $value ||| ";
                    }
                    print STDERR "\n";
=cut
                    
                }
                elsif( $line_string =~ /$option{ 'token-manual' }:(.*)/ )
                {
                    my $sentence = $1;
                    $sentence =~ s/\s+$//g;
                    $sentence =~ s/^\s+//g;
                    @words = split /\s+/, $sentence;
                    my $sentence_tmp;
                    foreach my $tmp_word ( @words )
                    {
                        if( $tmp_word =~ /<\d+>(.*)/ )
                        {
                            $sentence_tmp .= $1." ";
                        }
                        else
                        {
                            print STDERR "Warning: Format Error in $sentence_no line!\n";
                        }
                    }
                    $sentence_tmp =~ s/\s+$//g;
                    $sentence_tmp =~ s/^\s+//g;
                    print OUTPUTMARKDATA $sentence_tmp."\n";

                }
                elsif( $line_string =~ /$option{ 'del-label' }:(.*)/ )
                {
                    my $deleted_label = $1;
                    $deleted_label =~ s/\s+$//g;
                    $deleted_label =~ s/^\s+//g;

                    @deleted_labels = split /\s+/, $deleted_label;
                    $total_word_deletion_error += scalar( @deleted_labels );

                    foreach my $tmp_label (@deleted_labels)
                    {
                        my $new_deleted_label;
                        $new_deleted_label = $words_label_and_new{ $tmp_label };
                        ++$deleted_labels_new{ $new_deleted_label };
#                        print STDERR $new_deleted_label.$words[ $new_deleted_label - 1 ]."\n";
                    }
                    $last_label = 1;
                }

                if( $last_label eq 1 )
                {
                    last;
                }
            }

=pod
            my $key; 
            my $value;
            while( ( $key, $value ) = each %deleted_labels_new )
            {
                print STDERR "$key => $value ||| ";
            }
            print STDERR "\n";
=cut


            my $log_string;
            my @logs;
            while( $log_string = <INPUTDECLOG> )
            {
                $log_string =~ s/[\r\n]//g;
                if( $log_string =~ /\[\d+\]/ )
                {
#                    print STDERR $log_string."\n";
                    ;
                }
                elsif( $log_string =~ /\[(\d+), (\d+)\]: (.*)/ )
                {
                    if( $1 ne "0" and $1 ne ( scalar( @words ) + 1 ) )
                    {
                        my $domain1 = $1;
                        my $domain2 = $2;
                        my $domain3 = $3;
                        $domain1 =~ s/^\s+//g;
                        $domain1 =~ s/\s+$//g;
                        $domain2 =~ s/^\s+//g;
                        $domain2 =~ s/\s+$//g;
                        $domain3 =~ s/^\s+//g;
                        $domain3 =~ s/\s+$//g;
                        if( exists $deleted_labels_new{ $domain1 } and ( $domain2 - $domain1 - 1 ) eq 0 )
                        {
                            my @domain3_src_and_tgt;
                            @domain3_src_and_tgt = split /=>/,$domain3;
                            if( scalar( @domain3_src_and_tgt ) == 1 )
                            {
    #                            print STDERR "translation null ".$domain1." ".$words[ $domain1 - 1 ]."\n";
                                ++$error_number;
                                print LOGFILE "[$error_number]\n".
                                              "SENTENCE_NO=$sentence_no\n".
                                              "  START=".$domain1.
                                              " END=".$domain2.
                                              " SRC_AND_TGT=".$domain3.
                                              " ERROR=trans_null"."\n";
                                
                                
                                ++$trans_null;
                            } 
                            else
                            {
                                ++$error_number;
                                
                                $domain3_src_and_tgt[ 0 ] =~ s/\s+$//g;
                                $domain3_src_and_tgt[ 1 ] =~ s/^\s+//g;
                                my $word_align_tmp_here;
                                
                                if( exists $phrase_table{ $domain3_src_and_tgt[ 0 ].$domain3_src_and_tgt[ 1 ] } )
                                {
                                    $word_align_tmp_here = $phrase_table{ $domain3_src_and_tgt[ 0 ].$domain3_src_and_tgt[ 1 ] };
                                }
                                else
                                {
                                    $word_align_tmp_here = "OOV";
                                }
                                
                                
                                print LOGFILE "[$error_number]\n".
                                              "SENTENCE_NO=$sentence_no\n".
                                              "  START=".$domain1.
                                              " END=".$domain2.
                                              " SRC_AND_TGT=".$domain3.
                                              " ALIGN=".$word_align_tmp_here.
                                              " ERROR=trans_error"."\n";
                                
                                
                                ++$trans_error;
                            }
                            
                        }
                        elsif( ( $domain2 - $domain1 - 1 ) eq 0 )
                        {
#                            print STDERR "3 ||| ".$domain3."\n";
                            ;
                        }
                        else
                        {
                            my $current_pos_tmp = $domain1;
                            
                            my @src_and_tgt = split / => /,$domain3;
                            
                            for( $domain1..$domain2-1 )
                            {
                                if( exists $deleted_labels_new{ $current_pos_tmp } )
                                {
#                                    print STDERR $domain1." ||| ".$current_pos_tmp." ||| ".$domain3." ||| ".$phrase_table{ $src_and_tgt[ 0 ].$src_and_tgt[ 1 ] }."\n";
                                    
                                    my %word_alignments_hash;
                                    my $word_alignments_string = "";
                                    my @word_alignments;
                                    if( exists $phrase_table{ $src_and_tgt[ 0 ].$src_and_tgt[ 1 ] } )
                                    {
#                                        @word_alignments = split /\s+/,$phrase_table{ $src_and_tgt[ 0 ].$src_and_tgt[ 1 ] };
                                        $word_alignments_string = $phrase_table{ $src_and_tgt[ 0 ].$src_and_tgt[ 1 ] };
                                    }
                                    else
                                    {
#                                        @word_alignments = "";
#                                        print STDERR "Warning: SENTENCE_NO=$sentence_no $domain1 $domain3";
                                        $word_alignments_string = "";
                                    }
                                    @word_alignments = split /\s+/,$word_alignments_string;
                                    
                                    foreach my $word_align ( @word_alignments )
                                    {
                                        if( $word_align =~ /(\d+)-(\d+)/ )
                                        {
                                            ++$word_alignments_hash{ $1 };
                                        }
                                    }
                                    if( exists $word_alignments_hash{ $current_pos_tmp - $domain1 } )
                                    {
                                        ++$error_number;
                                        print LOGFILE "[$error_number]\n".
                                                      "SENTENCE_NO=$sentence_no\n".
                                                      "  START=".$domain1.
                                                      " CURRENT=".$current_pos_tmp.
                                                      " SRC_AND_TGT=".$domain3.
                                                      " ALIGN=".$word_alignments_string.
                                                      " ERROR=trans_error"."\n";

                                        ++$trans_error;
                                    }
                                    else
                                    {
                                        my $align_flag_left = 0;
                                        my $align_flag_right = 0;
                                        my $current_pos_this_tmp = 0;
                                        my @src_words = split /\s+/,$src_and_tgt[ 0 ];
#                                        print STDERR "THIS:".$src_and_tgt[ 0 ]." ".scalar( @src_words )." 0-".($current_pos_tmp-$domain1)." ".($current_pos_tmp - $domain1)."-".scalar( @src_words - 1 )."\n";
                                        
                                        
                                        for( 0..$current_pos_tmp - $domain1 )
                                        {
                                            if( exists $word_alignments_hash{ $current_pos_this_tmp } )
                                            {
                                                $align_flag_left = 1;
                                            }
                                            ++$current_pos_this_tmp;

                                        }
                                        
                                        $current_pos_this_tmp = $current_pos_tmp - $domain1;
                                        for( ($current_pos_tmp - $domain1)..scalar( @src_words - 1 ) )
                                        {
                                            if( exists $word_alignments_hash{ $current_pos_this_tmp } )
                                            {
                                                $align_flag_right = 1;
                                            }
                                            ++$current_pos_this_tmp;
                                        }
                                        
                                        if( $align_flag_left == 0 or $align_flag_right == 0 )
                                        {
                                            ++$trans_boundary_null;
                                            ++$error_number;
                                            my $word_alignments_string = "";
                                            if( exists $phrase_table{ $src_and_tgt[ 0 ].$src_and_tgt[ 1 ] } )
                                            {
                                                $word_alignments_string = $phrase_table{ $src_and_tgt[ 0 ].$src_and_tgt[ 1 ] };
                                            }
                                            print LOGFILE "[$error_number]\n".
                                                          "SENTENCE_NO=$sentence_no\n".
                                                          "  START=".$domain1.
                                                          " CURRENT=".$current_pos_tmp.
                                                          " SRC_AND_TGT=".$domain3.
                                                          " ALIGN=".$word_alignments_string.
                                                          " ERROR=boundary_null"."\n";
                                        }
                                        else
                                        {
                                            ++$trans_inter_null;
                                            ++$error_number;
                                            print LOGFILE "[$error_number]\n".
                                                          "SENTENCE_NO=$sentence_no\n".
                                                          "  START=".$domain1.
                                                          " CURRENT=".$current_pos_tmp.
                                                          " SRC_AND_TGT=".$domain3.
                                                          " ALIGN=".$phrase_table{ $src_and_tgt[ 0 ].$src_and_tgt[ 1 ] }.
                                                          " ERROR=inter_null ".$align_flag_left." ".$align_flag_right."\n";
                                        }
                                    }

                                }
                                ++$current_pos_tmp;
                            }
                        }
                    }
                }
                elsif( $log_string =~ /^====/ )
                {
                    last;
                }
            }
        }
        
        if( $line_no % 10000 == 0 )
        {
            print STDERR "\r  Processed $line_no lines. sentence_no=$sentence_no";
        }
    }
    print STDERR "\r  Processed $line_no lines. sentence_no=$sentence_no\n".
                 "trans_null=$trans_null trans_error=$trans_error trans_boundary_null=$trans_boundary_null trans_inter_null=$trans_inter_null\n".
                 "total_error=$total_word_deletion_error\n";
    print LOGFILE "sentence_no=$sentence_no trans_null=$trans_null trans_error=$trans_error trans_boundary_null=$trans_boundary_null trans_inter_null=$trans_inter_null total_error=$total_word_deletion_error\n";
    
    close( INPUTMARKDATA );
    close( OUTPUTMARKDATARAW );
    close( OUTPUTMARKDATA );
    close( INPUTDECLOG );
    close( LOGFILE );
}

sub getParameter
{
    if( ( scalar( @_ ) < 4 ) || ( scalar( @_ ) % 2 != 0 ) )
    {
        print STDERR "[USAGE]\n".
                     "         Error.Classifier.pl                 [OPTIONS]\n".
                     "[OPTION]\n".
                     "          -config   :  Config file.\n".
                     "          -markdata :  Manually Error Marked Data.\n".
                     "          -declog   :  Decoding Log.\n".
                     "          -pt       :  Phrase Table.\n".
                     "          -out      :  Classified Results.\n".
                     "          -log      :  Log File.\n".
                     "[EXAMPLE]\n".
                     "         perl Error.Classifier.pl       [-config   FILE]\n".
                     "                                        [-markdata FILE]\n".
                     "                                        [-declog   FILE]\n".
                     "                                        [-pt       FILE]\n".
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
         
    if( !exists $param{ "-markdata" } )
    {
        print STDERR "Error: please assign \"-markdata\"!\n";
        exit( 1 );
    }
    if( !exists $param{ "-declog" } )
    {
        print STDERR "Error: please assign \"-declog\"!\n";
        exit( 1 );
    }
          
    if( !exists $param{ "-pt" } )
    {
        print STDERR "Error: please assign \"-pt\"!\n";
        exit( 1 );
    }
    if( !exists $param{ "-out" } )
    {
        print STDERR "Error: please assign \"-out\"!\n";
        exit( 1 );
    }
    if( !exists $param{ "-log" } )
    {
        print STDERR "Error: please assign \"-log\"!\n";
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




