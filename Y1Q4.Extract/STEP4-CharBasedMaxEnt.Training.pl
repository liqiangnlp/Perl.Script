############################################################
#   version          : NiuTrans
#   Function         : Extract Sample
#   Author           : Qiang Li
#   Email            : liqiangneu@gmail.com
#   Date             : 2014-04-18
#   last Modified by :
#     2014-04-18 
##############################################################

use strict;

my $logo =   "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n".
             "#  MaxEnt Training                                                 #\n".
             "#                                                        NiuTrans  #\n".
             "#                                           liqiangneu\@gmail.com   #\n".
             "########### SCRIPT ########### SCRIPT ############ SCRIPT ##########\n";

print STDERR $logo;

my %param;

get_parameters( @ARGV );

maxent_training();



######
# Training me reordering model
sub maxent_training
{
    my $command = "";
    # maxent training
    print STDERR "\nStart training ME reordering model by maxent classfier...\nThis will take a while, please be patient...\n";
    $command = "../bin/maxent ".
               "-i 200 ".
               "-g 1 ".
               "-m $param{ \"-output\" } ".
               "$param{ \"-input\" } ".
               "--lbfgs";
    ssystem( $command );
}



######
# Getting parameters from command
sub get_parameters
{
    if( ( scalar( @_ ) < 4 ) || ( scalar( @_ ) % 2 != 0 ) )
    {
        print STDERR "[USAGE]\n".
                     "            MaxEnt.Training.pl                        [OPTIONS]\n".
                     "[OPTION]\n".
                     "                -input  :  input file\n".
                     "                -output :  output file\n".
                     "[EXAMPLE]\n".
                     "            perl MaxEnt.Training.pl              [-input    FILE]\n".
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





