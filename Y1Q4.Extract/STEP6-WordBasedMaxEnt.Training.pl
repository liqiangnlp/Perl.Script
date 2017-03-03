############################################################
#   version          : NiuTrans
#   Function         : Word-Based MaxEnt Training
#   Author           : Qiang Li
#   Email            : liqiangneu@gmail.com
#   Date             : 2014-05-04
#   last Modified by :
#     2014-05-04 
##############################################################

use strict;

my $logo =   "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n".
             "#  Word-Based MaxEnt Training                                      #\n".
             "#                                                        NiuTrans  #\n".
             "#                                           liqiangneu\@gmail.com   #\n".
             "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n";

print STDERR $logo;

my %param;

get_parameters( @ARGV );

sample_extraction();
maxent_training();
format_conversion( $param{ '-output' }.".step2", $param{ '-output' } );

######
# Samples Extraction
sub sample_extraction
{
	open( DELALNFILE, "<", $param{ '-delaln' } ) or die "Error: can not open file $param{ '-delaln' }.\n";
	open( POSDATFILE, "<", $param{ '-posdat' } ) or die "Error: can not open file $param{ '-posdat' }.\n";
	open( OUTPUTFILE, ">", $param{ '-output' }.".step1" ) or die "Error: can not open file $param{ '-output' }.step1.\n";
	open( LOGFILE,    ">", $param{ '-log' }    ) or die "Error: can not open file $param{ '-log' }.\n";
	
	my $line_no = 0;
	my $no_del = 0;
	while( <DELALNFILE> )
	{
		++$line_no;
		s/[\r\n]//g;

		my $pos_data = <POSDATFILE>;
		$pos_data =~ s/[\r\n]//g;

		
		if( $_ eq "" )
		{
			++$no_del;
			next;
		}
		
		my @del_aligns = split /\s+/, $_; 
		my %del_align_hash;
		foreach my $del_align ( @del_aligns )
		{
			if( $del_align =~ /(\d+)-(.*)-([\d.]+)/ )
			{
				$del_align_hash{ $1 } = $3;
			}
			else
			{
				print STDERR "\n Warning: Format error in $line_no line in $param{ '-delaln' } file.\n";
			}
		}
		
=pod
		my $key;
		my $value;
		while( ( $key, $value ) = each %del_align_hash )
		{
			print OUTPUTFILE $key." => ".$value."\n";
		}
=cut
		
		
		my @pos_data_vec = split /\s+/,$pos_data;
		my @words;
		my @poses;
		foreach my $word_pos ( @pos_data_vec )
		{
			if( $word_pos =~ /(.*)\/(.*)/ )
			{
				my $word = $1;
				my $pos = $2;
#				print OUTPUTFILE $1." ".$2." ||| ";
				if( $word ne "" and $pos ne "" )
				{
					push @words, $word;
					push @poses, $pos;
				}
				else
				{
					print STDERR "\nWarning: format error in $line_no line in $param{ '-posdat' } file.\n";
				}
			}
		}
		
		if( scalar( @words ) ne scalar( @poses ) )
		{
			print STDERR "\nWarning: format error in $line_no line in $param{ '-posdat' } file.\n";
		}
		
		my $src_pos = 0;
		foreach my $src_word ( @words )
		{
			++$src_pos;
			my $sample_string;
			if( exists $del_align_hash{ $src_pos } )
			{
				print LOGFILE "LINE=$line_no ".$src_pos." ".$words[ $src_pos - 1 ]." ".$del_align_hash{ $src_pos }." SPURIOUS\n";
				$sample_string .= "SPURIOUS ";
				if( $src_pos >= 3 )
				{
					$sample_string .= "w=".$words[ $src_pos - 1 ]." w-1=".$words[ $src_pos - 2 ]." w-2=".$words[ $src_pos - 3 ];
					$sample_string .= " p=".$poses[ $src_pos - 1 ]." p-1=".$poses[ $src_pos - 2 ]." p-2=".$poses[ $src_pos - 3 ];
				} 
				elsif( $src_pos == 2 )
				{
					$sample_string .= "w=".$words[ $src_pos - 1 ]." w-1=".$words[ $src_pos - 2 ]." w-2=NULL";
					$sample_string .= " p=".$poses[ $src_pos - 1 ]." p-1=".$poses[ $src_pos - 2 ]." p-2=NULL";
				}
				elsif( $src_pos == 1 )
				{
					$sample_string .= "w=".$words[ $src_pos - 1 ]." w-1=NULL"." w-2=NULL";
					$sample_string .= " p=".$poses[ $src_pos - 1 ]." p-1=NULL"." p-2=NULL";
				}
				
				if( $src_pos <= ( scalar( @words ) - 2 ) )
				{
					$sample_string .= " w+1=".$words[ $src_pos ]." w+2=".$words[ $src_pos + 1 ];
					$sample_string .= " p+1=".$poses[ $src_pos ]." p+2=".$poses[ $src_pos + 1 ];
				} 
				elsif( $src_pos == ( scalar( @words ) - 1 ) )
				{
					$sample_string .= " w+1=".$words[ $src_pos ]." w+2=NULL";
					$sample_string .= " p+1=".$poses[ $src_pos ]." p+2=NULL";
				}
				elsif( $src_pos == scalar( @words ) )
				{
					$sample_string .= " w+1=NULL"." w+2=NULL";
					$sample_string .= " p+1=NULL"." p+2=NULL";
				}
			}
			else
			{
				$sample_string .= "UNSPURIOUS ";
				if( $src_pos >= 3 )
				{
					$sample_string .= "w=".$words[ $src_pos - 1 ]." w-1=".$words[ $src_pos - 2 ]." w-2=".$words[ $src_pos - 3 ];
					$sample_string .= " p=".$poses[ $src_pos - 1 ]." p-1=".$poses[ $src_pos - 2 ]." p-2=".$poses[ $src_pos - 3 ];
				} 
				elsif( $src_pos == 2 )
				{
					$sample_string .= "w=".$words[ $src_pos - 1 ]." w-1=".$words[ $src_pos - 2 ]." w-2=NULL";
					$sample_string .= " p=".$poses[ $src_pos - 1 ]." p-1=".$poses[ $src_pos - 2 ]." p-2=NULL";
				}
				elsif( $src_pos == 1 )
				{
					$sample_string .= "w=".$words[ $src_pos - 1 ]." w-1=NULL"." w-2=NULL";
					$sample_string .= " p=".$poses[ $src_pos - 1 ]." p-1=NULL"." p-2=NULL";
				}
				
				if( $src_pos <= ( scalar( @words ) - 2 ) )
				{
					$sample_string .= " w+1=".$words[ $src_pos ]." w+2=".$words[ $src_pos + 1 ];
					$sample_string .= " p+1=".$poses[ $src_pos ]." p+2=".$poses[ $src_pos + 1 ];
				} 
				elsif( $src_pos == ( scalar( @words ) - 1 ) )
				{
					$sample_string .= " w+1=".$words[ $src_pos ]." w+2=NULL";
					$sample_string .= " p+1=".$poses[ $src_pos ]." p+2=NULL";
				}
				elsif( $src_pos == scalar( @words ) )
				{
					$sample_string .= " w+1=NULL"." w+2=NULL";
					$sample_string .= " p+1=NULL"." p+2=NULL";
				}
			}
			print OUTPUTFILE $sample_string."\n";
		}

=pod
		foreach my $word ( @words )
		{
			print OUTPUTFILE "$word ";
		}
		print OUTPUTFILE "\n";
		
		foreach my $pos ( @poses )
		{
			print OUTPUTFILE "$pos ";
		}
		print OUTPUTFILE "\n";
=cut
		
		
		
		if( $line_no % 1000 == 0 )
		{
			print STDERR "\r  Processed $line_no lines. NO_DEL=$no_del";
		}
	}
	print STDERR "\r  Processed $line_no lines. NO_DEL=$no_del\n";
	
	close( DELALNFILE );
	close( POSDATFILE );
	close( OUTPUTFILE );
	close( LOGFILE );
}


######
# Training me reordering model
sub maxent_training
{
    my $command = "";
    # maxent training
    print STDERR "\nStart training ME reordering model by maxent classfier...\nThis will take a while, please be patient...\n";
    $command = "bin/maxent ".
               "-i 200 ".
               "-g 1 ".
               "-m $param{ \"-output\" }.step2 ".
               "$param{ \"-output\" }.step1 ".
               "--lbfgs";
    ssystem( $command );
}

######
# Training me reordering model
sub format_conversion
{
	my $line_no = 0;
	my $features_count = 0;
	print STDERR "Get feature count...\n";
	open( INPUTFILE, "<", $_[ 0 ] ) or die "Error: can not open file ".$_[ 0 ].".\n";
	open ( OUTPUTFILE, ">", $_[ 1 ] ) or die "Error: can not open file ".$_[ 1 ].".\n";
	while( <INPUTFILE> )
	{
		++$line_no;
		s/[\r\n]//g;
		
		if( /^#/ )
		{
			next;
		}
		
		if( !/^\d+/ )
		{
			print STDERR "Error: format error in $line_no line.\n";
			exit( 1 );
		}
		
		$features_count = $_;
		last;
		
		if( $line_no % 1000 == 0 )
		{
			print STDERR "\r  Processed $line_no lines. Features_Count=$features_count"
		}
		
	}
	print STDERR "\r  Processed $line_no lines. Features_Count=$features_count\n";

	print STDERR "Reading features name...\n";
	my $current_features_count = 0;
	my @features;
	while( <INPUTFILE> )
	{
		++$line_no;
		++$current_features_count;
		s/[\r\n]//g;
		push @features, $_;
		
		if( $current_features_count eq $features_count )
		{
			last;
		}	
	}
	print STDERR "\r  Processed $line_no lines. Current_Features_Count=$current_features_count\n";


	print STDERR "Reading class name...\n";
	my $class_count = <INPUTFILE> or die $!;
	$class_count =~ s/[\r\n]//g;
	print STDERR "  class_count=$class_count\n";
	my @classes;
	++$line_no;
	for( 1..$class_count)
	{
		++$line_no;
		my $class = <INPUTFILE>;
		$class =~ s/[\r\n]//g;
		push @classes, $class;
		print STDERR "  FLAG=$class\n";
	}
	print STDERR "  Processed $line_no lines. class_count=$class_count\n";

	print STDERR "Reading feature-class mapping...\n";
	my $feature_class_num;
	my @features2;
	$current_features_count = 0;
	while( <INPUTFILE> )
	{
		++$line_no;
		++$current_features_count;
		s/[\r\n]//g;
		s/\s+$//g;
		my @tmp_features;
		( $feature_class_num, @tmp_features ) = split / +/,$_;
		foreach my $current_class ( @tmp_features )
		{
			push @features2, $current_class.":".$features[ $current_features_count - 1 ];
		}
		
		if( $current_features_count eq $features_count )
		{
			last;
		}
		
		if( $line_no % 1000 == 0 )
		{
			print STDERR "\r  Processed $line_no lines. Current_Features_Count=$current_features_count"
		}
	}
	print STDERR "\r  Processed $line_no lines. Current_Features_Count=$current_features_count\n";

	print STDERR "Reading feature weights...\n";
	my $feature_weight_num = <INPUTFILE> or die $!;
	$feature_weight_num =~ s/[\r\n]//g;
	
	print STDERR "  feature_weight_num=$feature_weight_num\n";
	if( $feature_weight_num != scalar( @features2 ) )
	{
		print STDERR "Error: feature weight num is wrong!\n";
		exit( 1 );
	}
	
	$current_features_count = 0;
	my %feature_final;
	while( <INPUTFILE> )
	{
		++$line_no;
		++$current_features_count;
		s/[\r\n]//g;
		$feature_final{ $features2[ $current_features_count -1 ] } = $_ + 0;
		print OUTPUTFILE $features2[ $current_features_count - 1 ]."\t".($_ + 0)."\n";

		if( $line_no % 1000 == 0 )
		{
			print STDERR "\r  Processed $line_no lines. Current_Features_Count=$current_features_count"
		}
	}
	print STDERR "\r  Processed $line_no lines. Current_Features_Count=$current_features_count\n";
	
	close( INPUTFILE );
	close( OUTPUTFILE );
=pod
	my $f1 = 'f=Îå';
	my $f2 = 'f=Äê';
	print STDERR "0:$f1=".$feature_final{ "0:$f1" }."\n";
	print STDERR "0:$f2=".$feature_final{ "0:$f2" }."\n";
	print STDERR "1:$f1=".$feature_final{ "1:$f1" }."\n";
	print STDERR "1:$f2=".$feature_final{ "1:$f2" }."\n";
	my $w1 = exp($feature_final{"0:$f1"} + $feature_final{"0:$f2"});
	my $w2 = exp($feature_final{"1:$f1"} + $feature_final{"1:$f2"});

	my $prob1 = $w1/($w1+$w2);
	my $prob2 = $w2/($w1+$w2);
	print STDERR $prob1, "\t", $prob2;
=cut
}



######
# Getting parameters from command
sub get_parameters
{
    if( ( scalar( @_ ) < 4 ) || ( scalar( @_ ) % 2 != 0 ) )
    {
        print STDERR "[USAGE]\n".
                     "            WordBasedMaxEnt.Training.pl                 [OPTIONS]\n".
                     "[OPTION]\n".
                     "                -delaln :  Input deletion alignment file.\n".
					 "                -posdat :  Input postag file.\n".
                     "                -output :  Output file\n".
					 "                -log    :  Log file.\n".
                     "[EXAMPLE]\n".
                     "            perl WordBasedMaxEnt.Training.pl     [-delaln   FILE]\n".
					 "                                                 [-posdat   FILE]\n".
					 "                                                 [-output   FILE]\n".
					 "                                                 [-log      FILE]\n";
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
     if( !exists $param{ "-delaln" } )
     {
         print STDERR "Error: Please assign the '-delaln' parameter!\n";
         exit( 1 );
     }
     if( !exists $param{ "-posdat" } )
     {
         print STDERR "Error: Please assign the '-posdat' parameter!\n";
         exit( 1 );
     }
     if( !exists $param{ "-output" } )
     {
         print STDERR "Error: Please assign the '-output' parameter!\n";
         exit( 1 );
     }
     if( !exists $param{ "-log" } )
     {
         print STDERR "Error: Please assign the '-log' parameter!\n";
         exit( 1 );
     }
	 
	 $param{ "-delaln" } =~ s/\\/\//g;
     $param{ "-posdat" } =~ s/\\/\//g;
	 $param{ "-output" } =~ s/\\/\//g;
     $param{ "-log" } =~ s/\\/\//g;
}


######
# Safe System
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
        printf STDERR "Error: Execution of: @_\n   die with signal %d, %s coredump\n", ($? & 127 ), ( $? & 128 ) ? 'with' : 'without';
        exit( 1 );
    }
    else
    {
        my $exitcode = $? >> 8;
        print STDERR "Exit code: $exitcode\n" if $exitcode;
        return ! $exitcode;
    }
}





