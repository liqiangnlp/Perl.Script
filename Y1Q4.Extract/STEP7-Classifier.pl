############################################################
#   version          : NiuTrans
#   Function         : Classifier
#   Author           : Qiang Li
#   Email            : liqiangneu@gmail.com
#   Date             : 2014-05-04
#   last Modified by :
#     2014-05-04
##############################################################

use strict;

my $logo =   "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n".
             "#  Classifier                                                      #\n".
             "#                                                        NiuTrans  #\n".
             "#                                           liqiangneu\@gmail.com   #\n".
             "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n";

print STDERR $logo;

my %param;
my %option;

get_parameters( @ARGV );
classifier();

sub classifier
{
	open( MAXENTMODEL, "<", $param{ '-maxent' } ) or die "Error: can not open file $param{ '-maxent' }.\n";
	open( INPUTFILE,   "<", $param{ '-input'  } ) or die "Error: can not open file $param{ '-input' }.\n";
	open( OUTPUTFILE,  ">", $param{ '-output' } ) or die "Error: can not open file $param{ '-output' }.\n";
	open( LOGFILE,     ">", $param{ '-log'    } ) or die "Error: can not open file $param{ '-log' }.\n";
	
	my $line_no = 0;
	my %maxent_hash;
	print STDERR "Loading maxent model from $param{ '-maxent' }...\n";
	while( <MAXENTMODEL> )
	{
		++$line_no;
		s/[\r\n]//g;
		my @feature_and_weight = split /\t+/, $_;
		if( scalar( @feature_and_weight ) ne 2 )
		{
			print STDERR "\nWarning: format error in $line_no line of $param{ '-maxent' } file.\n";
		}
		else
		{
			$maxent_hash{ $feature_and_weight[ 0 ] } = $feature_and_weight[ 1 ];
		}
		
		
		if( $line_no % 1000 == 0 )
		{
			print STDERR "\r  Processed $line_no lines.";
		}
	}
	print STDERR "\r  Processed $line_no lines.\n";

=pod
	my $key;
	my $value;
	while( ( $key, $value ) = each %maxent_hash )
	{
		print LOGFILE $key."\t".$value."\n";
	}
=cut

	print STDERR "Starting classifying $param{ '-input' }...\n";
	$line_no = 0;
	while( <INPUTFILE> )
	{
		++$line_no;
		s/[\r\n]//g;
		
		my @pos_data_vec = split /\s+/, $_;
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
			my $w0 = 0;
			my $w1 = 0;
			++$src_pos;
			my $sample_string;

			my $log_string = "[w0] [LINE:$line_no] [WORD:".$words[ $src_pos - 1 ]."] ";
			my $log_string_other ="[w1] [LINE:$line_no] [WORD:".$words[ $src_pos - 1 ]."] ";
			
			if( $src_pos >= 3 )
			{
				my $w_minus2 = $words[ $src_pos - 3 ];
				if( exists $maxent_hash{ "0:w-2=".$w_minus2 } )
				{
					$w0 += $maxent_hash{ "0:w-2=".$w_minus2 };
					$log_string .= "0:w-2=".$w_minus2." ".$maxent_hash{ "0:w-2=".$w_minus2 }." ";
				}
				if( exists $maxent_hash{ "1:w-2=".$w_minus2 } )
				{
					$w1 += $maxent_hash{ "1:w-2=".$w_minus2 };
					$log_string_other .= "1:w-2=".$w_minus2." ".$maxent_hash{ "1:w-2=".$w_minus2 }." ";
				}

				
				my $w_minus1 = $words[ $src_pos - 2 ];
				if( exists $maxent_hash{ "0:w-1=".$w_minus1 } )
				{
					$w0 += $maxent_hash{ "0:w-1=".$w_minus1 };
					$log_string .= "0:w-1=".$w_minus1." ".$maxent_hash{ "0:w-1=".$w_minus1 }." ";
				}
				if( exists $maxent_hash{ "1:w-1=".$w_minus1 } )
				{
					$w1 += $maxent_hash{ "1:w-1=".$w_minus1 };
					$log_string_other .= "1:w-1=".$w_minus1." ".$maxent_hash{ "1:w-1=".$w_minus1 }." ";
				}

				my $w = $words[ $src_pos - 1 ];
				if( exists $maxent_hash{ "0:w=".$w } )
				{
					$w0 += $maxent_hash{ "0:w=".$w };
					$log_string .= "0:w=".$w." ".$maxent_hash{ "0:w=".$w }." ";
				}
				if( exists $maxent_hash{ "1:w=".$w } )
				{
					$w1 += $maxent_hash{ "1:w=".$w };
					$log_string_other .= "1:w=".$w." ".$maxent_hash{ "1:w=".$w }." ";
				}
				
				my $p_minus2 = $poses[ $src_pos - 3 ];
				if( exists $maxent_hash{ "0:p-2=".$p_minus2 } )
				{
					$w0 += $maxent_hash{ "0:p-2=".$p_minus2 };
					$log_string .= "0:p-2=".$p_minus2." ".$maxent_hash{ "0:p-2=".$p_minus2 }." ";
				}
				if( exists $maxent_hash{ "1:p-2=".$p_minus2 } )
				{
					$w1 += $maxent_hash{ "1:p-2=".$p_minus2 };
					$log_string_other .= "1:p-2=".$p_minus2." ".$maxent_hash{ "1:p-2=".$p_minus2 }." ";
				}

				my $p_minus1 = $poses[ $src_pos - 2 ];
				if( exists $maxent_hash{ "0:p-1=".$p_minus1 } )
				{
					$w0 += $maxent_hash{ "0:p-1=".$p_minus1 };
					$log_string .= "0:p-1=".$p_minus1." ".$maxent_hash{ "0:p-1=".$p_minus1 }." ";
				}
				if( exists $maxent_hash{ "1:p-1=".$p_minus1 } )
				{
					$w1 += $maxent_hash{ "1:p-1=".$p_minus1 };
					$log_string_other .= "1:p-1=".$p_minus1." ".$maxent_hash{ "1:p-1=".$p_minus1 }." ";
				}
				
				my $p = $poses[ $src_pos - 1 ];
				if( exists $maxent_hash{ "0:p=".$p } )
				{
					$w0 += $maxent_hash{ "0:p=".$p };
					$log_string .= "0:p=".$p." ".$maxent_hash{ "0:p=".$p }." ";
				}
				if( exists $maxent_hash{ "1:p=".$p } )
				{
					$w1 += $maxent_hash{ "1:p=".$p };
					$log_string_other .= "1:p=".$p." ".$maxent_hash{ "1:p=".$p }." ";
				}
				
#				print LOGFILE $log_string."\n";
			} 
			elsif( $src_pos == 2 )
			{
#				$sample_string .= "w=".$words[ $src_pos - 1 ]." w-1=".$words[ $src_pos - 2 ]." w-2=NULL";
#				$sample_string .= " p=".$poses[ $src_pos - 1 ]." p-1=".$poses[ $src_pos - 2 ]." p-2=NULL";

				my $w_minus2 = "NULL";
				if( exists $maxent_hash{ "0:w-2=".$w_minus2 } )
				{
					$w0 += $maxent_hash{ "0:w-2=".$w_minus2 };
					$log_string .= "0:w-2=".$w_minus2." ".$maxent_hash{ "0:w-2=".$w_minus2 }." ";
				}
				if( exists $maxent_hash{ "1:w-2=".$w_minus2 } )
				{
					$w1 += $maxent_hash{ "1:w-2=".$w_minus2 };
					$log_string_other .= "1:w-2=".$w_minus2." ".$maxent_hash{ "1:w-2=".$w_minus2 }." ";
				}

				my $w_minus1 = $words[ $src_pos - 2 ];
				if( exists $maxent_hash{ "0:w-1=".$w_minus1 } )
				{
					$w0 += $maxent_hash{ "0:w-1=".$w_minus1 };
					$log_string .= "0:w-1=".$w_minus1." ".$maxent_hash{ "0:w-1=".$w_minus1 }." ";
				}
				if( exists $maxent_hash{ "1:w-1=".$w_minus1 } )
				{
					$w1 += $maxent_hash{ "1:w-1=".$w_minus1 };
					$log_string_other .= "1:w-1=".$w_minus1." ".$maxent_hash{ "1:w-1=".$w_minus1 }." ";
				}

				my $w = $words[ $src_pos - 1 ];
				if( exists $maxent_hash{ "0:w=".$w } )
				{
					$w0 += $maxent_hash{ "0:w=".$w };
					$log_string .= "0:w=".$w." ".$maxent_hash{ "0:w=".$w }." ";
				}
				if( exists $maxent_hash{ "1:w=".$w } )
				{
					$w1 += $maxent_hash{ "1:w=".$w };
					$log_string_other .= "1:w=".$w." ".$maxent_hash{ "1:w=".$w }." ";
				}
				
				my $p_minus2 = "NULL";
				if( exists $maxent_hash{ "0:p-2=".$p_minus2 } )
				{
					$w0 += $maxent_hash{ "0:p-2=".$p_minus2 };
					$log_string .= "0:p-2=".$p_minus2." ".$maxent_hash{ "0:p-2=".$p_minus2 }." ";
				}
				if( exists $maxent_hash{ "1:p-2=".$p_minus2 } )
				{
					$w1 += $maxent_hash{ "1:p-2=".$p_minus2 };
					$log_string_other .= "1:p-2=".$p_minus2." ".$maxent_hash{ "1:p-2=".$p_minus2 }." ";
				}

				my $p_minus1 = $poses[ $src_pos - 2 ];
				if( exists $maxent_hash{ "0:p-1=".$p_minus1 } )
				{
					$w0 += $maxent_hash{ "0:p-1=".$p_minus1 };
					$log_string .= "0:p-1=".$p_minus1." ".$maxent_hash{ "0:p-1=".$p_minus1 }." ";
				}
				if( exists $maxent_hash{ "1:p-1=".$p_minus1 } )
				{
					$w1 += $maxent_hash{ "1:p-1=".$p_minus1 };
					$log_string_other .= "1:p-1=".$p_minus1." ".$maxent_hash{ "1:p-1=".$p_minus1 }." ";
				}

				my $p = $poses[ $src_pos - 1 ];
				if( exists $maxent_hash{ "0:p=".$p } )
				{
					$w0 += $maxent_hash{ "0:p=".$p };
					$log_string .= "0:p=".$p." ".$maxent_hash{ "0:p=".$p }." ";
				}
				if( exists $maxent_hash{ "1:p=".$p } )
				{
					$w1 += $maxent_hash{ "1:p=".$p };
					$log_string_other .= "1:p=".$p." ".$maxent_hash{ "1:p=".$p }." ";
				}
			
			}
			elsif( $src_pos == 1 )
			{
#				$sample_string .= "w=".$words[ $src_pos - 1 ]." w-1=NULL"." w-2=NULL";
#				$sample_string .= " p=".$poses[ $src_pos - 1 ]." p-1=NULL"." p-2=NULL";
				
				my $w_minus2 = "NULL";
				if( exists $maxent_hash{ "0:w-2=".$w_minus2 } )
				{
					$w0 += $maxent_hash{ "0:w-2=".$w_minus2 };
					$log_string .= "0:w-2=".$w_minus2." ".$maxent_hash{ "0:w-2=".$w_minus2 }." ";
				}
				if( exists $maxent_hash{ "1:w-2=".$w_minus2 } )
				{
					$w1 += $maxent_hash{ "1:w-2=".$w_minus2 };
					$log_string_other .= "1:w-2=".$w_minus2." ".$maxent_hash{ "1:w-2=".$w_minus2 }." ";
				}

				my $w_minus1 = "NULL";
				if( exists $maxent_hash{ "0:w-1=".$w_minus1 } )
				{
					$w0 += $maxent_hash{ "0:w-1=".$w_minus1 };
					$log_string .= "0:w-1=".$w_minus1." ".$maxent_hash{ "0:w-1=".$w_minus1 }." ";
				}
				if( exists $maxent_hash{ "1:w-1=".$w_minus1 } )
				{
					$w1 += $maxent_hash{ "1:w-1=".$w_minus1 };
					$log_string_other .= "1:w-1=".$w_minus1." ".$maxent_hash{ "1:w-1=".$w_minus1 }." ";
				}

				my $w = $words[ $src_pos - 1 ];
				if( exists $maxent_hash{ "0:w=".$w } )
				{
					$w0 += $maxent_hash{ "0:w=".$w };
					$log_string .= "0:w=".$w." ".$maxent_hash{ "0:w=".$w }." ";
				}
				if( exists $maxent_hash{ "1:w=".$w } )
				{
					$w1 += $maxent_hash{ "1:w=".$w };
					$log_string_other .= "1:w=".$w." ".$maxent_hash{ "1:w=".$w }." ";
				}
				
				my $p_minus2 = "NULL";
				if( exists $maxent_hash{ "0:p-2=".$p_minus2 } )
				{
					$w0 += $maxent_hash{ "0:p-2=".$p_minus2 };
					$log_string .= "0:p-2=".$p_minus2." ".$maxent_hash{ "0:p-2=".$p_minus2 }." ";
				}
				if( exists $maxent_hash{ "1:p-2=".$p_minus2 } )
				{
					$w1 += $maxent_hash{ "1:p-2=".$p_minus2 };
					$log_string_other .= "1:p-2=".$p_minus2." ".$maxent_hash{ "1:p-2=".$p_minus2 }." ";
				}

				my $p_minus1 = "NULL";
				if( exists $maxent_hash{ "0:p-1=".$p_minus1 } )
				{
					$w0 += $maxent_hash{ "0:p-1=".$p_minus1 };
					$log_string .= "0:p-1=".$p_minus1." ".$maxent_hash{ "0:p-1=".$p_minus1 }." ";
				}
				if( exists $maxent_hash{ "1:p-1=".$p_minus1 } )
				{
					$w1 += $maxent_hash{ "1:p-1=".$p_minus1 };
					$log_string_other .= "1:p-1=".$p_minus1." ".$maxent_hash{ "1:p-1=".$p_minus1 }." ";
				}

				my $p = $poses[ $src_pos - 1 ];
				if( exists $maxent_hash{ "0:p=".$p } )
				{
					$w0 += $maxent_hash{ "0:p=".$p };
					$log_string .= "0:p=".$p." ".$maxent_hash{ "0:p=".$p }." ";
				}
				if( exists $maxent_hash{ "1:p=".$p } )
				{
					$w1 += $maxent_hash{ "1:p=".$p };
					$log_string_other .= "1:p=".$p." ".$maxent_hash{ "1:p=".$p }." ";
				}
				
			}
			
			if( $src_pos <= ( scalar( @words ) - 2 ) )
			{
#				$sample_string .= " w+1=".$words[ $src_pos ]." w+2=".$words[ $src_pos + 1 ];
#				$sample_string .= " p+1=".$poses[ $src_pos ]." p+2=".$poses[ $src_pos + 1 ];
				
				my $w_plus1 = $words[ $src_pos ];
				if( exists $maxent_hash{ "0:w+1=".$w_plus1 } )
				{
					$w0 += $maxent_hash{ "0:w+1=".$w_plus1 };
					$log_string .= "0:w+1=".$w_plus1." ".$maxent_hash{ "0:w+1=".$w_plus1 }." ";
				}
				if( exists $maxent_hash{ "1:w+1=".$w_plus1 } )
				{
					$w1 += $maxent_hash{ "1:w+1=".$w_plus1 };
					$log_string_other .= "1:w+1=".$w_plus1." ".$maxent_hash{ "1:w+1=".$w_plus1 }." ";
				}

				my $w_plus2 = $words[ $src_pos + 1 ];
				if( exists $maxent_hash{ "0:w+2=".$w_plus2 } )
				{
					$w0 += $maxent_hash{ "0:w+2=".$w_plus2 };
					$log_string .= "0:w+2=".$w_plus2." ".$maxent_hash{ "0:w+2=".$w_plus2 }." ";
				}
				if( exists $maxent_hash{ "1:w+2=".$w_plus2 } )
				{
					$w1 += $maxent_hash{ "1:w+2=".$w_plus2 };
					$log_string_other .= "1:w+2=".$w_plus2." ".$maxent_hash{ "1:w+2=".$w_plus2 }." ";
				}

				my $p_plus1 = $poses[ $src_pos ];
				if( exists $maxent_hash{ "0:p+1=".$p_plus1 } )
				{
					$w0 += $maxent_hash{ "0:p+1=".$p_plus1 };
					$log_string .= "0:p+1=".$p_plus1." ".$maxent_hash{ "0:p+1=".$p_plus1 }." ";
				}
				if( exists $maxent_hash{ "1:p+1=".$p_plus1 } )
				{
					$w1 += $maxent_hash{ "1:p+1=".$p_plus1 };
					$log_string_other .= "1:p+1=".$p_plus1." ".$maxent_hash{ "1:p+1=".$p_plus1 }." ";
				}

				my $p_plus2 = $poses[ $src_pos + 1 ];
				if( exists $maxent_hash{ "0:p+2=".$p_plus2 } )
				{
					$w0 += $maxent_hash{ "0:p+2=".$p_plus2 };
					$log_string .= "0:p+2=".$p_plus2." ".$maxent_hash{ "0:p+2=".$p_plus2 }." ";
				}
				if( exists $maxent_hash{ "1:p+2=".$p_plus2 } )
				{
					$w1 += $maxent_hash{ "1:p+2=".$p_plus2 };
					$log_string_other .= "1:p+2=".$p_plus2." ".$maxent_hash{ "1:p+2=".$p_plus2 }." ";
				}
			} 
			elsif( $src_pos == ( scalar( @words ) - 1 ) )
			{
#				$sample_string .= " w+1=".$words[ $src_pos ]." w+2=NULL";
#				$sample_string .= " p+1=".$poses[ $src_pos ]." p+2=NULL";
				
				my $w_plus1 = $words[ $src_pos ];
				if( exists $maxent_hash{ "0:w+1=".$w_plus1 } )
				{
					$w0 += $maxent_hash{ "0:w+1=".$w_plus1 };
					$log_string .= "0:w+1=".$w_plus1." ".$maxent_hash{ "0:w+1=".$w_plus1 }." ";
				}
				if( exists $maxent_hash{ "1:w+1=".$w_plus1 } )
				{
					$w1 += $maxent_hash{ "1:w+1=".$w_plus1 };
					$log_string_other .= "1:w+1=".$w_plus1." ".$maxent_hash{ "1:w+1=".$w_plus1 }." ";
				}

				my $w_plus2 = "NULL";
				if( exists $maxent_hash{ "0:w+2=".$w_plus2 } )
				{
					$w0 += $maxent_hash{ "0:w+2=".$w_plus2 };
					$log_string .= "0:w+2=".$w_plus2." ".$maxent_hash{ "0:w+2=".$w_plus2 }." ";
				}
				if( exists $maxent_hash{ "1:w+2=".$w_plus2 } )
				{
					$w1 += $maxent_hash{ "1:w+2=".$w_plus2 };
					$log_string_other .= "1:w+2=".$w_plus2." ".$maxent_hash{ "1:w+2=".$w_plus2 }." ";
				}

				my $p_plus1 = $poses[ $src_pos ];
				if( exists $maxent_hash{ "0:p+1=".$p_plus1 } )
				{
					$w0 += $maxent_hash{ "0:p+1=".$p_plus1 };
					$log_string .= "0:p+1=".$p_plus1." ".$maxent_hash{ "0:p+1=".$p_plus1 }." ";
				}
				if( exists $maxent_hash{ "1:p+1=".$p_plus1 } )
				{
					$w1 += $maxent_hash{ "1:p+1=".$p_plus1 };
					$log_string_other .= "1:p+1=".$p_plus1." ".$maxent_hash{ "1:p+1=".$p_plus1 }." ";
				}

				my $p_plus2 = "NULL";
				if( exists $maxent_hash{ "0:p+2=".$p_plus2 } )
				{
					$w0 += $maxent_hash{ "0:p+2=".$p_plus2 };
					$log_string .= "0:p+2=".$p_plus2." ".$maxent_hash{ "0:p+2=".$p_plus2 }." ";
				}
				if( exists $maxent_hash{ "1:p+2=".$p_plus2 } )
				{
					$w1 += $maxent_hash{ "1:p+2=".$p_plus2 };
					$log_string_other .= "1:p+2=".$p_plus2." ".$maxent_hash{ "1:p+2=".$p_plus2 }." ";
				}
			}
			elsif( $src_pos == scalar( @words ) )
			{
#				$sample_string .= " w+1=NULL"." w+2=NULL";
#				$sample_string .= " p+1=NULL"." p+2=NULL";
				
				my $w_plus1 = "NULL";
				if( exists $maxent_hash{ "0:w+1=".$w_plus1 } )
				{
					$w0 += $maxent_hash{ "0:w+1=".$w_plus1 };
					$log_string .= "0:w+1=".$w_plus1." ".$maxent_hash{ "0:w+1=".$w_plus1 }." ";
				}
				if( exists $maxent_hash{ "1:w+1=".$w_plus1 } )
				{
					$w1 += $maxent_hash{ "1:w+1=".$w_plus1 };
					$log_string_other .= "1:w+1=".$w_plus1." ".$maxent_hash{ "1:w+1=".$w_plus1 }." ";
				}

				my $w_plus2 = "NULL";
				if( exists $maxent_hash{ "0:w+2=".$w_plus2 } )
				{
					$w0 += $maxent_hash{ "0:w+2=".$w_plus2 };
					$log_string .= "0:w+2=".$w_plus2." ".$maxent_hash{ "0:w+2=".$w_plus2 }." ";
				}
				if( exists $maxent_hash{ "1:w+2=".$w_plus2 } )
				{
					$w1 += $maxent_hash{ "1:w+2=".$w_plus2 };
					$log_string_other .= "1:w+2=".$w_plus2." ".$maxent_hash{ "1:w+2=".$w_plus2 }." ";
				}

				my $p_plus1 = "NULL";
				if( exists $maxent_hash{ "0:p+1=".$p_plus1 } )
				{
					$w0 += $maxent_hash{ "0:p+1=".$p_plus1 };
					$log_string .= "0:p+1=".$p_plus1." ".$maxent_hash{ "0:p+1=".$p_plus1 }." ";
				}
				if( exists $maxent_hash{ "1:p+1=".$p_plus1 } )
				{
					$w1 += $maxent_hash{ "1:p+1=".$p_plus1 };
					$log_string_other .= "1:p+1=".$p_plus1." ".$maxent_hash{ "1:p+1=".$p_plus1 }." ";
				}

				my $p_plus2 = "NULL";
				if( exists $maxent_hash{ "0:p+2=".$p_plus2 } )
				{
					$w0 += $maxent_hash{ "0:p+2=".$p_plus2 };
					$log_string .= "0:p+2=".$p_plus2." ".$maxent_hash{ "0:p+2=".$p_plus2 }." ";
				}
				if( exists $maxent_hash{ "1:p+2=".$p_plus2 } )
				{
					$w1 += $maxent_hash{ "1:p+2=".$p_plus2 };
					$log_string_other .= "1:p+2=".$p_plus2." ".$maxent_hash{ "1:p+2=".$p_plus2 }." ";
				}
			}
			
			my $prob0 = exp( $w0 ) / ( exp( $w0 ) + exp( $w1 ) );
			my $prob1 = exp( $w1 ) / ( exp( $w0 ) + exp( $w1 ) );
			
			print LOGFILE $log_string."w0=".$w0."\n";
			print LOGFILE $log_string_other."w1=".$w1."\n";
			print LOGFILE "prob0=$prob0\tprob1=$prob1\n";
			if( $prob0 < $prob1 )
			{
				print LOGFILE "SPURIOUS\n";
			}
			
			print OUTPUTFILE $sample_string."\n";
		}
		
		
		
		if( $line_no % 100 == 0 )
		{
			print STDERR "\r  Processed $line_no lines.";
		}
	}
	print STDERR "\r  Processed $line_no lines.\n";
	
	
	close( MAXENTMODEL );
	close( INPUTFILE );
	close( OUTPUTFILE );
	close( LOGFILE );
}



######
# Getting parameters from command
sub get_parameters
{
    if( ( scalar( @_ ) < 2 ) || ( scalar( @_ ) % 2 != 0 ) )
    {
        print STDERR "[USAGE]\n".
                     "            Classifier.pl                             [OPTIONS]\n".
                     "[OPTION]\n".
                     "                -maxent  :  Maxent Model file.\n".
                     "                -input   :  Inputted file.\n".
                     "                -output  :  Outputted file.\n".
                     "                -log     :  log file\n".
                     "[EXAMPLE]\n".
                     "            perl WordAlignment.Format.Convert.pl [-maxent FILE]\n".
					 "                                                 [-input  FILE]\n".
					 "                                                 [-output FILE]\n".
					 "                                                 [-log    FILE]\n";
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
     if( !exists $param{ "-maxent" } )
     {
         print STDERR "Error: Please assign the '-maxent' parameter!\n";
         exit( 1 );
     }
     if( !exists $param{ "-input" } )
     {
         print STDERR "Error: Please assign the '-input' parameter!\n";
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
	 

	 
}

