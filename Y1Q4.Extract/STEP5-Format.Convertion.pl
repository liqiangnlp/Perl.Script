############################################################
#   version          : NiuTrans
#   Function         : Format Conversion
#   Author           : Qiang Li
#   Email            : liqiangneu@gmail.com
#   Date             : 2014-04-18
#   last Modified by :
#     2014-04-18 
##############################################################

use strict;

my $logo =   "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n".
             "#  Format Conversion                                              #\n".
             "#                                                        NiuTrans  #\n".
             "#                                           liqiangneu\@gmail.com   #\n".
             "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n";

print STDERR $logo;

my %param;

get_parameters( @ARGV );

open( INPUTFILE, "<", $param{ "-input" } ) or die "Error: can not open file $param{ \"-input\" }.\n";
open( OUTPUTFILE, ">", $param{ "-output" } ) or die "Error: can not open file $param{ \"-output\" }.\n";



format_conversion();




close( INPUTFILE );
close( OUTPUTFILE );


######
# Training me reordering model
sub format_conversion
{
	my $line_no = 0;
	my $features_count = 0;
	print STDERR "Get feature count...\n";
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
	
=pod
	my $f1 = 'f=五';
	my $f2 = 'f=年';
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
                     "            Format.Conversion.pl                        [OPTIONS]\n".
                     "[OPTION]\n".
                     "                -input  :  input file\n".
                     "                -output :  output file\n".
                     "[EXAMPLE]\n".
                     "            perl Format.Conversion.pl            [-input    FILE]\n".
					 "                                                 [-output   FILE]\n";
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
	 
	 $param{ "-input" } =~ s/\\/\//g;
     $param{ "-output" } =~ s/\\/\//g;
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





